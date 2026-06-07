/**
 * Commit-msg guard — Pi extension
 *
 * Enforces AGENTS.md §3 commit format on the Pi agent's bash tool. The
 * required shape is:
 *
 *   <type>: <short summary>
 *
 *   Reasoning:
 *   - What done: <specific changes>
 *   - What next: <what should happen after this commit>
 *   - Risk: <anything that could break or needs testing>
 *
 * Strategy: hook `tool_call`, look for `git commit`, extract the message
 * from `-m` / `--message` flags (joined with newlines as git does), and
 * validate. Cases we can't statically parse — interactive editor, `-F file`,
 * heredoc, mixed `-m` + `-F` — fail open with a soft warn. Better to allow a
 * commit than to block legitimate work we can't inspect.
 *
 * Limits: this only fires for bash commands issued by the Pi agent. It does
 * not cover `!git commit` from user-bash (would need a `user_bash` handler).
 * For coverage across all entry points, a `.git/hooks/commit-msg` script is
 * the universal alternative — install via `scripts/install-hooks.sh`.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const REQUIRED_HEADING = /^Reasoning:\s*$/m;
const REQUIRED_LABELS = ["What done:", "What next:", "Risk:"] as const;

const GIT_COMMIT_RE = /\bgit\s+commit\b/;

const TEMPLATE = [
	"<type>: <short summary>",
	"",
	"Reasoning:",
	"- What done: <specific changes>",
	"- What next: <what should happen after this commit>",
	"- Risk: <anything that could break or needs testing>",
].join("\n");

/**
 * Tokenize a shell command string, respecting single quotes, double quotes
 * (with backslash escapes), and backslash escapes outside quotes. Returns
 * null if quoting is malformed — caller should fail open in that case.
 */
function tokenize(input: string): string[] | null {
	const tokens: string[] = [];
	let i = 0;
	const n = input.length;

	while (i < n) {
		while (i < n && /\s/.test(input[i])) i++;
		if (i >= n) break;

		let token = "";
		let inSingle = false;
		let inDouble = false;

		while (i < n) {
			const c = input[i];
			if (inSingle) {
				if (c === "'") {
					inSingle = false;
					i++;
				} else {
					token += c;
					i++;
				}
			} else if (inDouble) {
				if (c === "\\" && i + 1 < n) {
					token += input[i + 1];
					i += 2;
				} else if (c === '"') {
					inDouble = false;
					i++;
				} else {
					token += c;
					i++;
				}
			} else {
				if (c === "'") {
					inSingle = true;
					i++;
				} else if (c === '"') {
					inDouble = true;
					i++;
				} else if (c === "\\" && i + 1 < n) {
					token += input[i + 1];
					i += 2;
				} else if (/\s/.test(c)) {
					break;
				} else {
					token += c;
					i++;
				}
			}
		}

		// Unterminated quote → malformed, let it through.
		if (inSingle || inDouble) return null;
		tokens.push(token);
	}
	return tokens;
}

/** Locate the `git commit` invocation in the token list (skip wrappers like
 *  `sudo`, `env VAR=x`, etc.). Returns the index of `git` (commit is at +1). */
function findGitCommitIndex(tokens: string[]): number {
	for (let i = 0; i < tokens.length; i++) {
		if (tokens[i] === "git" && tokens[i + 1] === "commit") return i;
	}
	return -1;
}

type ExtractResult =
	| { kind: "flags"; message: string }
	| { kind: "file" | "none" | "mixed" }
	| { kind: "error" };

/** Inspect args after `git commit` and figure out where the message comes from. */
function extractMessage(tokens: string[], startIdx: number): ExtractResult {
	let message = "";
	let sawMessageFlag = false;
	let sawFileFlag = false;

	for (let i = startIdx + 2; i < tokens.length; i++) {
		const tok = tokens[i];

		if (tok === "-m" || tok === "--message") {
			const val = tokens[++i];
			if (val === undefined) return { kind: "error" };
			message += (sawMessageFlag ? "\n" : "") + val;
			sawMessageFlag = true;
		} else if (tok.startsWith("-m=") || tok.startsWith("--message=")) {
			message += (sawMessageFlag ? "\n" : "") + tok.slice(tok.indexOf("=") + 1);
			sawMessageFlag = true;
		} else if (tok === "-F" || tok === "--file" || tok === "--file-with-branch" || tok === "-F-") {
			if (tok === "-F-") {
				// stdin → can't parse
				sawFileFlag = true;
				continue;
			}
			const val = tokens[++i];
			if (val === undefined) return { kind: "error" };
			sawFileFlag = true;
		} else if (tok.startsWith("-F=") || tok.startsWith("--file=") || tok.startsWith("--file-with-branch=")) {
			sawFileFlag = true;
		}
		// All other flags (--amend, -a, --allow-empty, etc.) ignored.
	}

	if (sawFileFlag && sawMessageFlag) return { kind: "mixed" };
	if (sawFileFlag) return { kind: "file" };
	if (!sawMessageFlag) return { kind: "none" };
	return { kind: "flags", message };
}

type Validation = { ok: true } | { ok: false; missing: string[] };

function validateFormat(message: string): Validation {
	const missing: string[] = [];
	if (!REQUIRED_HEADING.test(message)) missing.push("`Reasoning:` heading");
	for (const label of REQUIRED_LABELS) {
		if (!message.includes(label)) missing.push(`\`${label.slice(0, -1)}\` line`);
	}
	return missing.length === 0 ? { ok: true } : { ok: false, missing };
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return;

		const command: string = event.input.command ?? "";
		if (!GIT_COMMIT_RE.test(command)) return;

		const tokens = tokenize(command);
		if (!tokens) return; // Malformed quoting — fail open.

		const startIdx = findGitCommitIndex(tokens);
		if (startIdx === -1) return; // Regex lied to us — fail open.

		const extracted = extractMessage(tokens, startIdx);

		if (extracted.kind === "file" || extracted.kind === "none" || extracted.kind === "mixed") {
			// Can't inspect: editor, -F file, stdin, mixed flags. Soft warn.
			if (ctx.hasUI) {
				ctx.ui.notify(
					"git commit: message not parseable — verify it follows AGENTS.md §3",
					"info",
				);
			}
			return;
		}

		if (extracted.kind === "error") return; // Truncated args — fail open.

		const check = validateFormat(extracted.message);
		if (check.ok) return;

		const reason =
			`Commit message missing required sections per AGENTS.md §3: ${check.missing.join(", ")}.\n\n` +
			`Expected format:\n${TEMPLATE}`;

		if (ctx.hasUI) {
			ctx.ui.notify("Commit blocked: message doesn't follow AGENTS.md §3", "error");
		}
		return { block: true, reason };
	});
}
