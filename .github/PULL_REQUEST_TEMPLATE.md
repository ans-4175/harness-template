## Summary

<!-- 1–3 sentences: what this PR changes and why. -->

## Type of change

- [ ] Bug fix (no behavior change for users)
- [ ] New hook / script / skill
- [ ] Rule or section change in `AGENTS.md` or `docs/`
- [ ] Documentation only
- [ ] Refactor (no behavior change)
- [ ] Breaking change (call out below)

## Related issue

<!-- Link the issue this closes, or "None". Use "Closes #123" to auto-close. -->

Closes #

## Changes

<!-- Bulleted, scannable list of what changed. For a new skill, include its directory and description. -->

-

## Test plan

<!-- How you verified it works. For hook or script changes, mention which agent you tested with. -->

- [ ] Read `docs/STATUS.md` before starting
- [ ] If a code change: ran `bash scripts/agent-lint.sh`
- [ ] Verified the build and lint steps the harness references
- [ ] Smoke-tested the new hook, script, or skill end-to-end

## Reasoning

<!-- Mirrors AGENTS.md §3, the commit-message reasoning log. The "why" matters as much as the "what". -->

- **What done:**
- **What next:**
- **Risk:**

## Checklist

- [ ] Followed the rules in `AGENTS.md`
- [ ] Added a handoff record to `docs/STATUS.md` (AGENTS.md §5), and a `noted` entry in `docs/LESSONS.md` if the work produced a reusable correction (§6)
- [ ] No secrets / `.env` / credentials committed
- [ ] Files in `.claude/`, `.pi/`, `scripts/` match the conventions used elsewhere in the repo
