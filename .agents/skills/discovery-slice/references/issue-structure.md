# Issue Structure: Epic and Task Anatomy

> This anatomy is **tracker-agnostic**. "Epic", "sub-issue", and "relation" are generic terms. The default tracker is GitHub Issues through the `gh` CLI; the project's actual tracker is named in `CONTRIBUTING.md` ("Issues and labels").

## Hierarchy

```
Epic (parent issue)  =  one slice, one JTBD, one phase
├── Task (sub-issue) =  a sub-JTBD or a self-contained area of work
├── Task
│   └── [relation] -> another issue to read as context
└── Task
```

---

## Task granularity: flat vs sub-issues

**Flat task**: use when the work is straightforward, one area, and the AC fits in at most 3 Gherkin items.

**Split into sub-issues** when:
- The task spans several independent areas that can be done separately
- It is not straightforward: there is uncertainty or several possible approaches (consider a spike first)
- The AC has more than 5 items, a sign the task is too big
- Each sub-issue must still be vertically meaningful: demonstrable, not "frontend only" or "backend only"

**Vertical completeness test:** a good task can be demoed to a non-engineer. If it touches a single technical layer and the result is not visible to a user, it is probably an AC item, not a task.

---

## Epic anatomy

```markdown
## Background
[One paragraph: which JTBD this slice solves, in which phase, and why it matters now.
Link related issues if any.]

## Scope
**In:** [short bullets of what is built]
**Out:** [what is deliberately deferred to a later phase]

## Acceptance Criteria
- [ ] [verifiable outcome criterion - can the user complete their job?]
- [ ] [outcome criterion]

## What's Next
[One sentence: after this epic, which slice becomes the next priority]
```

Epic AC stays high-level and behavioural: "does this slice deliver the value it promised?" No Gherkin here; the Given/When/Then detail belongs in the tasks.

---

## Task (sub-issue) anatomy

```markdown
## Job Story
When [situation], I want to [action], so I can [outcome].

## Design / Solution Notes
[Optional - only when a design or technical decision needs explaining before work starts.
Not a detailed spec: direction and limits are enough.]

## Acceptance Criteria
- [ ] Given [starting condition], When [user/system action], Then [verifiable result]
- [ ] Given [starting condition], When [user/system action], Then [verifiable result]

## Notes
[Optional - edge cases, PRD references, target platform, or non-obvious decisions]

## What's Next
[After this task, which tasks need to know the result or can start]
```

**Gherkin AC is required** for all tasks and sub-issues: `Given [starting condition], When [action], Then [verifiable result]`. Without clear AC, an agent cannot know when a task is done.

---

## Spike anatomy

Use a spike when uncertainty is high: the solution is unknown and needs investigation before implementation can be estimated or started. A spike delivers a decision, not a feature.

```markdown
## Spike Goal
[The concrete question that must be answered before implementation can start.]

## Investigation Scope
- [area or approach to research]
- [area or approach to research]

## Expected Output
[What exists at the end: a decision doc, a proof of concept, an estimate, or draft AC for the next task]

## Time Box
[The time limit. If it is not done within it, escalate to the human]
```

A spike is a flat issue, not a sub-issue. Reference it from the epic that follows once the spike is done.

---

## Naming conventions

**Epic:** `[short JTBD] - Phase [N]`
```
Daily Deal Review - Phase 1
Stale Deal Detection - Phase 1
```

**Task:** `[area or feature delivered independently]`
```
Deal list view with lead-time indicator           ok
Needs-attention sidebar                           ok
Add lastActivityAt field to GET /api/deals        wrong (this is an AC item, not a task)
```

**Spike:** `[topic] - Spike`
```
Auth Strategy - Spike                             ok
Export PDF Performance - Spike                    ok
```

A task is a deliverable unit, not a technical step.
