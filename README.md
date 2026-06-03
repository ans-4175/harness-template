# Agent Workflow Template

A drop-in set of guardrails for AI coding agents working on any project. It gives an agent three things:

1. **`AGENTS.md`** — the rules an agent must follow (push/deploy flow, commit reasoning logs, status protocol).
2. **`scripts/agent-lint.sh`** — a pre-push lint: two AI review phases (a magic-string audit and a simplify pass) plus a deterministic STATUS.md gate.
3. **`docs/STATUS.md`** — a push journal so the next agent (or you) knows what was pushed and why.

It is **language-neutral**: build/lint/deploy commands are placeholders you fill in once.

## Layout

```
.
├── AGENTS.md                    # agent rules (read first)
├── CLAUDE.md -> AGENTS.md       # symlink, so CLAUDE-based agents read the same rules
├── docs/
│   └── STATUS.md                # push journal (seeded, ready to append to)
└── scripts/
    ├── agent-lint.sh            # orchestrator: 2 AI phases + the deterministic status gate
    ├── check-constants.prompt   # phase 1 — magic strings/numbers audit (read-only, AI)
    ├── check-simplify.prompt    # phase 2 — simplify changed files, then verify build (AI)
    └── check-status.sh          # phase 3 — deterministic STATUS.md gate (no AI; exit 1 = must update)
```

## Setup

1. **Copy** these files into your project root (keep the `scripts/` and `docs/` layout).
2. **Replace the placeholders** below across all files (a single find/replace per token):

   | Placeholder | Replace with | Example |
   |-------------|-------------|---------|
   | `{{PROJECT_NAME}}` | Your project name | `Acme API` |
   | `{{MAIN_BRANCH}}` | Your default branch | `main` |
   | `{{BUILD_CMD}}` | Command that builds / typechecks | `npm run build`, `cargo build`, `make` |
   | `{{LINT_CMD}}` | Command that lints (optional) | `npm run lint`, `ruff check .` |
   | `{{DEPLOY_CMD}}` | Command that deploys | `npm run deploy`, `flyctl deploy` |

   Quick one-liner (run from the copied folder, edit the values first):
   ```bash
   grep -rl '{{' . --exclude-dir=.git | while read -r f; do
     sed -i '' \
       -e 's/{{PROJECT_NAME}}/Acme API/g' \
       -e 's/{{MAIN_BRANCH}}/main/g' \
       -e 's#{{BUILD_CMD}}#npm run build#g' \
       -e 's#{{LINT_CMD}}#npm run lint#g' \
       -e 's#{{DEPLOY_CMD}}#npm run deploy#g' \
       "$f"
   done
   ```
   (Drop the `''` after `-i` on Linux/GNU sed.)

3. **Make the scripts executable:** `chmod +x scripts/*.sh .claude/hooks/*.sh`
4. **Install an AI CLI** the script can call — it auto-detects `pi`, `claude`, or `opencode` (first one found wins).
5. **Recreate the symlink** if your copy method didn't preserve it:
   ```bash
   ln -sf AGENTS.md CLAUDE.md
   ```
   (Or just keep two copies / delete `CLAUDE.md` if your agent only reads `AGENTS.md`.)

## How it works

- Run `bash scripts/agent-lint.sh` before pushing. It runs the 3 phases sequentially and streams each phase's output straight to your terminal.
- **Phase 1** (constants) is a read-only AI report. **Phase 2** (simplify) is an AI pass that **edits** changed files (simplifications only) and verifies the build. **Phase 3** is a deterministic shell gate — `scripts/check-status.sh` — that exits 1 if there are code changes without a `docs/STATUS.md` update, meaning you **must** update STATUS.md before pushing.
- For phases 1 & 2 the pass/fail follows the AI CLI's **exit code** (read the output yourself for the actual findings); phase 3 has a real deterministic exit code that genuinely gates the push.
- The build/lint/deploy commands themselves live in the prompts and `AGENTS.md`, not hardcoded in the orchestrator, which is why the script is language-neutral.

## Claude Code integration (optional)

If your agent is **Claude Code**, the template also ships a native `.claude/` layer so you don't
have to spawn a nested CLI. It reuses the same assets — the slash commands point straight at the
existing `.prompt` files (one source of truth), and the push guard delegates to the same
`scripts/check-status.sh` used by the bash harness.

```
.claude/
├── settings.json                # PreToolUse hook (committed — team config)
├── hooks/
│   └── pre-push-guard.sh         # blocks `git push` if code changes lack a STATUS.md update
└── commands/
    ├── agent-lint.md             # /agent-lint — runs all 3 phases in-session
    ├── check-constants.md        # /check-constants — reads scripts/check-constants.prompt
    └── check-simplify.md         # /check-simplify — reads scripts/check-simplify.prompt
```

- **`/agent-lint`** runs the three phases natively in the current session (no nested `claude -p`).
- **The hook** fires on every `Bash` tool call; if the command is a `git push` and there are code
  changes not accompanied by a `docs/STATUS.md` update, it blocks with exit code 2 and tells the
  agent what to fix. It **fails open** — if `jq`/`git`/the main branch aren't available, the push
  proceeds rather than getting stuck.
- Requires **`jq`** on PATH for the hook. `.claude/settings.local.json` (personal overrides) is
  gitignored; `.claude/settings.json` is committed.

The two modes coexist: use the **bash harness** (`scripts/agent-lint.sh`) in CI or with other
agent CLIs, and the **`.claude/` layer** when working inside Claude Code.

## Customizing

- **Add or remove a phase:** add another `.prompt` file and a `run_prompt` line in `agent-lint.sh`.
- **Change the audit rules:** the prompts are plain text — edit `check-constants.prompt` / `check-simplify.prompt` to match your conventions.
- **Different AI CLI:** add it to the detection block at the top of `agent-lint.sh`.
