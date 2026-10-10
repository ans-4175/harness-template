---
name: discovery-slice
description: "Review PRD readiness, then break a PRD into JTBDs, thin vertical slices, and a Phase Map; optionally create epics and tasks in the project's issue tracker. Use when a PRD exists and needs review or slicing, a new project phase starts, or the Phase Map needs updating. Triggers: 'review the PRD', 'is this PRD ready', 'break down the JTBDs', 'make a phase map', 'slice the next phase', 'create epics'."
---

# Discovery & Slice

## Step 0 - Is the PRD ready to slice?

Before extracting JTBDs, check that the PRD has enough to work from. Read `references/prd-checklist.md` and evaluate each section.

Three outcomes:

- **Ready**: all sections present. Go to Step 1.
- **Slice with caution**: 1-2 sections are thin but workable. Show the gaps to the human, get explicit acknowledgment, and record them as assumptions in the Phase Map. Then continue.
- **Needs rewrite first**: Business Context, User Segments, or Pain Points/JTBD are missing or too vague. Stop and report what is missing. Slicing now builds on assumptions that are expensive to fix mid-sprint.

On "needs rewrite", list the specific gaps so the human can decide. Do not go to Step 1 without agreement.

## Step 1 - Read the PRD

Read the PRD file (usually `docs/plans/prd.md`). Extract:

- Business context and goals
- User segments
- Pain points
- Flows and behaviours

## Step 2 - Identify the JTBDs

Extract every Job-to-be-Done from the PRD, one per block:

```
Job: [short name]
When: [user situation]
I want to: [motivation]
So I can: [outcome]
```

Classify each as **primary** (high frequency, can stand alone) or **secondary** (extends a primary job, depends on an existing foundation).

Propose the list to the human and wait for confirmation, corrections, or additions.

## Step 3 - Find the thinnest slice per JTBD

For each JTBD, decide the thinnest end-to-end slice: the minimum that lets a user complete that job. That is Phase 1. Everything else goes to "Next value".

Checklist per slice:

- [ ] Can be described in one sentence from the user's point of view
- [ ] Has UI, logic, and data, end to end
- [ ] The happy path is complete
- [ ] Does not wait on another slice to be tried
- [ ] Can be finished in one sprint

## Step 4 - Build the Phase Map

Group the JTBDs into phases: primary JTBDs first with the thinnest slices; later phases thicken existing slices or add new JTBDs.

Write to `docs/plans/phase-map.md` (create the folder if missing). Template and rules: `references/phase-map.md`. Confirm the phase grouping with the human **before** writing the file.

## Step 5 - Create epics and tasks (only if the project uses an issue tracker)

Read the tracker from `CONTRIBUTING.md` ("Issues and labels"). The default is **GitHub Issues** through the `gh` CLI. If the project has no tracker (`N/A`), stop at Step 4: the Phase Map is the deliverable.

First check access (`command -v gh`, then `gh auth status`, then a read-only call such as `gh repo view`). If the CLI is missing or unauthenticated, stop and report it. Do not install tooling or try other accounts.

For each slice in the agreed phase, create:

1. **Epic**: one per slice. Title `[short JTBD] - Phase [N]`. Fill Background, Scope (in/out), Acceptance Criteria (high-level behavioural outcomes, not Gherkin), and What's Next.
2. **Tasks**: sub-issues under each epic. One task is one independently deliverable area, not a technical step. Granularity rule: flat if straightforward with at most 3 AC items; split into sub-issues if there are several independent areas, an unclear approach, or more than 5 AC items.
3. **Spike**: a flat issue before any task whose solution is not yet known. A spike delivers a decision, not a feature.
4. **Relations**: link tasks that share context or depend on each other.

Vertical completeness check: a task's output must be demonstrable to a non-engineer. If the work touches one technical layer and produces nothing a user can see, it is an AC item, not a task.

AC format for tasks and sub-issues is Gherkin: `Given [starting condition], When [action], Then [verifiable result]`.

On GitHub, link tasks to their epic with a task list in the epic body (`- [ ] #123`), or use native sub-issues if the repository has them enabled.

Full anatomy templates, granularity rules, spike anatomy, and naming: `references/issue-structure.md`.

---

## Human collaboration points

Propose and discuss at each step. Do not execute unilaterally:

- **Step 0**: report the PRD assessment and gaps before deciding to proceed or stop
- **Step 2**: share the JTBD list and ask for review before classifying
- **Step 3**: share the slice boundaries and ask if anything feels too thick or too thin
- **Step 4**: confirm the phase grouping before writing the file
- **Step 5**: confirm the epic/task structure before creating anything in the tracker
