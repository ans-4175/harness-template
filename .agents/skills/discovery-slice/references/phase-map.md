# Phase Map Template

Save to `docs/plans/phase-map.md` in the repo.

```markdown
# Phase Map: [Project Name]

> [One sentence: what is being built, for whom.]
> PRD: [path to the PRD file]
> Last updated: [date]

---

## Phase 1: [Phase name]

**Goal:** What can a user do at the end of this phase that they could not do before?

| JTBD | Slice in this phase | Next value |
|---|---|---|
| [job name] | [thinnest end-to-end deliverable] | [what gets added in a later phase] |

---

## Phase 2: [Phase name]

**Goal:** ...

| JTBD | Slice in this phase | Next value |
|---|---|---|
| [job name] | [deliverable] | - |

---

## Dependency notes

- Phase 2 -> [JTBD X] needs data from Phase 1 [JTBD Y]
- [other dependencies, if any]
```

## Rules

- The Phase Map is not a spec. A big-picture view is enough; the detail lives in the project's issue tracker.
- The "Next value" column shows the next value per JTBD, not a phase name.
- Update the Phase Map only when scope changes between phases. Say why in the commit message.
- When a task is finished, mark it Done in the tracker. Do not delete it from the Phase Map.
