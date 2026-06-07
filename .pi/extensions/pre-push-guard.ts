/**
 * Pre-push guard — Pi extension
 *
 * Mirrors `.claude/hooks/pre-push-guard.sh` for the Pi agent. Blocks `git push`
 * when `docs/STATUS.md` has not been updated this push (per AGENTS.md §2 & §4).
 *
 * Delegates the actual decision to `scripts/check-status.sh` — the same single
 * source of truth that the Claude Code hook uses, so both agents enforce the
 * same gate. Adding a new check? Update the script, not this file.
 *
 * Fail-open: if the check script is missing or exec fails unexpectedly, the
 * push proceeds. Better to allow a push than to silently break a workflow.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync } from "node:fs";
import { join } from "node:path";

const SCRIPT_REL = "scripts/check-status.sh";

// Match `git push` as a standalone subcommand. Word boundaries prevent false
// positives like `git pushy` or `git-push-alias`. Case-sensitive to match the
// Claude Code hook's behaviour.
const GIT_PUSH_RE = /\bgit\s+push\b/;

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		// Only act on the bash tool. Other tools (write, edit, ...) aren't push.
		if (event.toolName !== "bash") return;

		const command: string = event.input.command ?? "";
		if (!GIT_PUSH_RE.test(command)) return;

		// Resolve the check script relative to the project root (cwd of pi).
		const scriptPath = join(process.cwd(), SCRIPT_REL);
		if (!existsSync(scriptPath)) {
			// Fail open — the script is the source of truth, so without it we
			// can't enforce the gate. Don't silently break the workflow.
			return;
		}

		let result: { code: number; stderr: string } | undefined;
		try {
			result = await pi.exec("bash", [scriptPath], { signal: ctx.signal });
		} catch {
			// Exec itself failed — fail open.
			return;
		}

		// Exit 0 = STATUS.md is in order (or no code changes since main).
		if (result.code === 0) return;

		// Exit 1 = code changes present but STATUS.md not in this push.
		const reason = result.stderr.trim() || "docs/STATUS.md must be updated before pushing.";

		if (ctx.hasUI) {
			ctx.ui.notify("Push blocked: docs/STATUS.md needs a journal entry", "warning");
		}
		return { block: true, reason };
	});
}
