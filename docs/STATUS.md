# {{PROJECT_NAME}} Status

> **Agents: READ THIS FILE before starting any work.** Protocol: `AGENTS.md` §5.
> Curated operational state, not a commit log or a deploy log. Update the snapshot
> sections **in place**; add **one handoff record per push**, newest first.
> Never record secrets, credentials, PII, or internal URLs with credentials.

## Current snapshot

<!-- TODO(fill): Facts about the repo as it is now, as short bullets: stack and versions,
     branch model, how it runs, key integrations, who consumes it. Prefer pointers to files
     over copying them. Read volatile facts (HEAD, latest tag) from git, not from here. -->

- Integration branch: `{{MAIN_BRANCH}}`.

## Active work / blockers

<!-- Open risks and what blocks progress. Never silently remove an unresolved blocker. -->

- None recorded.

## Last verified

<!-- What was actually run, when, and the result. Say what did NOT run. Replace rows in
     place when a check is re-run; do not stack repeats of an unchanged result. -->

| Date | Check | Result |
|------|-------|--------|
| — | `{{BUILD_CMD}}` | Not yet run |

## Durable decisions

<!-- Decisions that still bind future work. Keep the "why" short. Remove one only when it
     is truly superseded, and say so in a handoff record. -->

- None recorded.

## Handoff records

<!-- One record per push, newest first. Format:
     - YYYY-MM-DD [tag] What was pushed and why. Evidence: <command, PR/MR, commit>. Next: <step>.
     Suggested tags: feature, fix, docs, chore, infra, review, harness. -->

- None recorded.

## Historical recap

<!-- Compacted older records. See AGENTS.md §5 for the compaction thresholds. -->

None compacted yet.
