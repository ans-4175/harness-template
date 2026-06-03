---
description: Run the pre-push agent lint (constants audit, simplify, STATUS check) natively in this session
allowed-tools: Read Edit Write Bash Grep Glob
---

Run the pre-push **agent lint** natively in this session — the same three phases as `scripts/agent-lint.sh`, but in-session (no nested CLI). Do them in order and summarize each:

1. **Phase 1 — Magic strings & numbers audit.** Read `scripts/check-constants.prompt` and follow it exactly. Read-only; report findings.
2. **Phase 2 — Simplify changed files.** Read `scripts/check-simplify.prompt` and follow it exactly. Apply safe simplifications, then verify the build.
3. **Phase 3 — STATUS.md check.** Read `scripts/check-status.prompt` and follow it exactly. Report whether `docs/STATUS.md` needs updating.

Finish with a short PASS / WARNING summary per phase.
