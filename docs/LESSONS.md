# {{PROJECT_NAME}} Lessons

Reusable corrections that change how later work is done. **Append-only.** This is not a
changelog (git history and `docs/STATUS.md` cover that). Protocol: `AGENTS.md` §6.

## Before you add an entry

- It must pass the test: *would this still help someone on a different task next month?*
  If it only answers "where are we now", it belongs in `docs/STATUS.md`.
- It needs evidence (command and result, failing test, commit, or code path).
- It must be safe to commit: no credentials, `.env` contents, data dumps, or customer data.
- Leaving this file unchanged after a task is normal.

## States

| State | Meaning | Who sets it |
|-------|---------|-------------|
| `noted` | Recorded by the agent under the protocol. Not yet confirmed by a human. | The agent. Every new entry starts here. |
| `verified` | Confirmed by a human. | **Only when a human asks.** An agent never promotes its own entry. |

Never delete an entry. If a later entry corrects it, add `Superseded by: <title>` to the old
one and cite the old one in the new entry's Context.

## Entry format

```md
### <One-line rule, phrased as what to do>

- **State:** noted
- **Context:** What went wrong or nearly went wrong, and where.
- **Evidence:** Command and result, failing test, commit, or code path.
- **Decision:** What later authors should do instead.
- **Validation:** How the correction was checked (or "not yet checked").
```

Optional fields: `Rejected alternative:` (and why), `Superseded by:`.

---

<!-- Entries below, in the order they were added (oldest first). -->

No lessons recorded yet.
