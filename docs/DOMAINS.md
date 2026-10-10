# Domain map

**Per-domain mode is OFF while this table is empty.** The repo uses a single
`docs/STATUS.md` and `docs/LESSONS.md`. Protocol: `AGENTS.md` §5 ("Scale").

Turn it on when one repo serves several areas and unrelated branches keep editing the same
lines of the global files. A domain is identified by **what a change touches**, not by who
wrote it.

| Domain | Touches (paths, route prefixes, tables, external scopes) | Status file | Lessons file |
|--------|-----------------------------------------------------------|-------------|--------------|
<!-- | `example` | `src/example/**`, `tests/example/` | `docs/status/example.md` | `docs/lessons/example.md` | -->

Order rows by how often a domain changes (hot first), not alphabetically.

## Adding a domain

1. Add the row above in the same PR/MR that introduces the first change for it.
2. Copy `docs/status/_TEMPLATE.md` to `docs/status/<domain>.md`.
3. Copy `docs/lessons/_TEMPLATE.md` to `docs/lessons/<domain>.md`.

## Where a change is written

- One **primary domain** per change: its handoff record and lessons go in that domain's files.
- A second domain touched: one pointer line there (record title and PR/MR), never a copy.
- The global `docs/STATUS.md` changes only for repo-wide facts: infrastructure, test gate, CI/release, cross-domain blockers.
- A change that fits no row is repo-wide and goes in the global files. Local tooling and agent/contributor docs are repo-wide by default.
