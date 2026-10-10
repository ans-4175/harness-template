# Agent Rules — {{PROJECT_NAME}}

> **Read this before doing ANY work.** Then read `docs/STATUS.md` to learn the current state.
> `CLAUDE.md` is a symlink to this file. Edit `AGENTS.md` only.

---

## 0. First-Time Setup (do this before anything else)

This file was created from a template. Before following any rule below, look for
unfilled placeholders (ignore matches inside this §0 itself):

```bash
grep -rnE '\{\{[A-Z_]+\}\}|TODO\(fill\)' . --exclude-dir=.git --exclude=README.md
```

There are two kinds, and they are handled differently:

| Kind | Looks like | How to fill it |
|------|------------|----------------|
| **Value** | `{{PROJECT_NAME}}` | Short value. Ask the user, then replace every occurrence across all files. |
| **Section** | `<!-- TODO(fill): ... -->` | Longer content. **Discover it from the repo first** (manifest files, CI config, `git log`, existing docs), write what you can verify, and ask the user only for what the repo cannot tell you. Never invent a command or a policy. |

Values:

| Placeholder | Meaning | Example |
|-------------|---------|---------|
| `{{PROJECT_NAME}}` | The project's name | `Acme API` |
| `{{MAIN_BRANCH}}` | The default / integration branch | `main` |
| `{{BUILD_CMD}}` | Command that builds or typechecks | `npm run build`, `cargo build` |
| `{{LINT_CMD}}` | Command that lints (optional) | `npm run lint`, `ruff check .` |
| `{{TEST_CMD}}` | Command that runs tests (optional) | `npm test`, `pytest` |

If something does not apply (no linter, no issue tracker), replace the placeholder with
`N/A` or delete the section — do not leave it half-filled.

**`docs/STATUS.md` and `docs/LESSONS.md` start empty on purpose.** Fill them from one of:

- **Values the user gives you** (stack, branch model, known blockers, decisions).
- **The repo itself**, when the user asks you to explore it: read `git log` (recent history and
  merge/PR subjects), manifests and CI config, existing docs, and code comments such as
  `TODO`/`FIXME`/`HACK`. Write only what you can point to. Mark each inferred fact with its source
  (file, commit, or command) and leave out anything you could not verify.

Do not invent history, and do not write lessons from guesses: a lesson needs evidence (§6).

Once the grep returns nothing, delete this section and continue.

---

## 1. Read First

Every session, before changing anything:

1. Read `docs/STATUS.md`: **Current snapshot**, **Active work / blockers**, **Last verified**,
   **Durable decisions**. Read **Handoff records** that relate to the task.
2. Read `docs/LESSONS.md`, and any entry that covers the area you are about to change.
3. If `docs/DOMAINS.md` has rows (per-domain mode, see §5), also read the status and lessons
   file of every domain the task touches.
4. For setup, local run, validation, branch and review rules, use `CONTRIBUTING.md`. Do not
   improvise commands that file already defines.
5. Before implementing or checking a change, read `docs/QA.md` (self-check loop and evidence format).
6. Run `git status -sb` before editing. Preserve work you did not create.

---

## 2. Project Overview & Conventions

<!-- TODO(fill): What this repository does and who uses it, in 3-8 lines. Say what it owns
     and what it deliberately does not (e.g. "product scope lives in repo X"). -->

### Commands

| Purpose | Command |
|---------|---------|
| Build / typecheck | `{{BUILD_CMD}}` |
| Lint | `{{LINT_CMD}}` |
| Test | `{{TEST_CMD}}` |

### Architecture & conventions

<!-- TODO(fill): Only what an agent must follow and cannot see from the code: directory
     layout and where to start for common changes, naming, layering, framework gotchas,
     generated output that must not be edited. Keep it stable; operational state belongs in
     docs/STATUS.md, not here. Delete this block if there is nothing to add. -->

### Environment

<!-- TODO(fill): Config and secrets the project needs and where each comes from. List names
     only, never values. Delete if not applicable. -->

| Var | Source |
|-----|--------|
| `<EXAMPLE_VAR>` | `<secret manager, .env, CI variable, ...>` |

---

## 3. Commit Rules

Every commit MUST include a reasoning log. This is **not** a git log — it is a thinking trail.

```
<type>: <short summary>

Reasoning:
- What done: <specific changes>
- What next: <what should happen after this commit>
- Risk: <anything that could break or needs testing>
```

Example:

```
feat: add request retry with exponential backoff

Reasoning:
- What done: Wrapped the upstream fetch in a 3-attempt retry with backoff
- What next: Monitor error rate to confirm transient failures drop
- Risk: None — build passes; behavior unchanged on the happy path
```

Do not commit unless the user has asked for it.

---

## 4. Push Rules

When the user asks to push (any branch):

1. Run agent lint:
   ```bash
   bash scripts/agent-lint.sh
   ```
   Three phases, in order:
   1. **Magic strings/numbers audit** (AI, read-only): reports literals that should be named constants.
   2. **Simplify changed files** (AI, edits): readability fixes on changed files only, then verifies `{{BUILD_CMD}}`.
   3. **STATUS gate** (deterministic, no AI): fails if code changed but `docs/STATUS.md` (or a `docs/status/*.md` file) is not part of this push.
2. After phases 1 and 2 pass, **add a handoff record** to `docs/STATUS.md` (§5) and stage it so phase 3 passes. Add a lesson (§6) if the work produced one.
3. Push.

> **Claude Code:** the same lint runs in-session as `/agent-lint` (or `/check-constants`,
> `/check-simplify`). A `PreToolUse` hook blocks `git push` when the STATUS gate fails.
> **Pi:** `.pi/extensions/` enforces the same push gate and the commit format in §3.

**Every push updates STATUS.** Local commits that are not pushed do not.

---

## 5. STATUS Protocol (Mandatory)

`docs/STATUS.md` answers: *where does the repo stand, what was decided, what comes next.*
It is point-in-time and may go stale, so it carries evidence and dates. It is **not** a
commit log and **not** a deploy log.

### Structure

| Section | Holds | Updated |
|---------|-------|---------|
| Current snapshot | Facts about the repo as it is now | In place |
| Active work / blockers | Open risks and what blocks progress | In place |
| Last verified | What was actually run, when, with what result | In place |
| Durable decisions | Decisions that still bind future work | In place |
| Handoff records | One record per push, newest first | Appended |
| Historical recap | Compacted older records | When compacting |

### Before working

Read `docs/STATUS.md` (§1). Note every "Next" and open blocker left by the previous agent.

### After pushing

1. Update the snapshot sections **in place** if anything they describe changed.
2. Add one handoff record at the top of **Handoff records**:
   `- YYYY-MM-DD [tag] What was pushed and why. Evidence: <command, PR/MR, commit>. Next: <step>.`
3. Stage and commit it with the push (§4).

Record verification honestly: say exactly what ran, and what did **not** run.
Never record secrets, credentials, PII, internal URLs with credentials, or raw thought process.

### Compact in place when a file exceeds

- 1,000 lines, **or** 80 KB, **or** 100 handoff records.

Keep the snapshot sections and unresolved context. Keep the 50-70 most recent records and
summarize older resolved ones under **Historical recap**. Never silently drop an unresolved
blocker or a still-valid decision. Do not create a separate archive file.

### Scale: one file or per domain

Default is a single `docs/STATUS.md` and `docs/LESSONS.md`. When one repo serves several
areas and unrelated branches keep editing the same lines, switch to **per-domain mode**:

- Map the domains in `docs/DOMAINS.md` (it ships empty; per-domain mode is **off** until it has rows).
- Each domain gets `docs/status/<domain>.md` and `docs/lessons/<domain>.md` from the `_TEMPLATE.md` files.
- Read the global files plus the files of every domain the task touches.
- A change has **one primary domain**. Write its handoff record and lessons there. If a second
  domain is touched, add a one-line pointer in that domain's file, never a copy.
- Update the global `docs/STATUS.md` only for repo-wide facts: infrastructure, test gate, CI/release, cross-domain blockers.
- A change that fits no row is repo-wide and goes in the global files.

---

## 6. LESSONS Protocol

`docs/LESSONS.md` answers: *what must a later author do differently to avoid repeating this
correction.* It is append-only and is not a changelog.

**One-sentence test:** if the note still helps someone on a different task next month, it is
a lesson. If it answers "where are we now", it is status. When a mistake produced both a
decision and a rule, split it: the decision goes in STATUS, the rule goes in LESSONS.

A lesson is a correction that changes how the next change is made, from any source: a human
instruction, a failing test, a smoke check, or a near-miss caught in review.

### Lifecycle: two states

| State | Meaning | Who sets it |
|-------|---------|-------------|
| `noted` | Recorded by the agent under this protocol. Not yet confirmed by a human. | The agent. Every new entry starts here. |
| `verified` | Confirmed by a human. | **Only when a human asks for it.** |

- An agent **never** promotes its own entry to `verified`, even when the evidence is strong.
- Entries are never deleted. If a later entry corrects an earlier one, add `Superseded by: <title>` to the old entry and cite the old one in the new entry's Context.
- Evidence (command, test, commit, code path) is recorded in the entry. A claim with no evidence is not a lesson yet.

### When to write one

Before pushing (§4), ask whether the work produced a reusable correction. Leaving the file
unchanged is normal and expected. Do not add routine progress, product scope, credentials,
or unverified guesses.

### Where it goes

Global `docs/LESSONS.md` holds repo-wide mechanics and lessons that apply to more than one
domain. In per-domain mode, a lesson tied to one domain goes in `docs/lessons/<domain>.md`;
move it to the global file when it proves to apply further, and leave a one-line pointer.

---

## 7. Git Workflow & Safety Boundaries

Branch naming, merge/pull-request flow, issues, and releases are defined in `CONTRIBUTING.md`.

- Never commit directly to `{{MAIN_BRANCH}}` or any protected branch.
- Do not commit, push, open a PR/MR, comment, or deploy unless the user authorizes that specific action.
- **Never deploy on your own initiative.** Deploy only when the user explicitly asks.
- Never commit secrets, `.env*`, tokens, keys, or real customer data.
- Do not weaken a check to get green: no skipped tests, no lowered thresholds, no blanket lint-disable.
- Do not overwrite or revert work you did not create.
- Do not change CI, deploy config, or release versions unless the task is explicitly about it.

<!-- TODO(fill): Project-specific safety boundaries: shared or production services that must
     not be touched, destructive operations, areas that are known to be fragile.
     Delete this block if there are none. -->

---

## 8. Definition of Done

Before handing off a change:

1. Run the self-check loop in `docs/QA.md` to the depth its risk tier requires.
2. `git diff --check`, then review the diff for secrets, generated output, and unrelated files.
3. `{{BUILD_CMD}}` passes. Run `{{LINT_CMD}}` and `{{TEST_CMD}}` where they exist (the smallest meaningful subset is fine for a focused change).
4. Docs-only change: links, commands, and facts re-checked against the tree.
5. Update `docs/STATUS.md` (§5) and, if the work produced a reusable correction, `docs/LESSONS.md` (§6).
6. State what was verified and what was **not**, using the evidence block in `docs/QA.md`. Do not present unit-level checks as end-to-end proof.

<!-- TODO(fill): Extra project gates (e.g. coverage threshold, schema/DDL handoff, visual QA).
     Delete if none. -->

---

## 9. Skills

Workflow skills live in `.agents/skills/` (Claude Code finds them through symlinks in
`.claude/skills/`). Load a skill when its situation comes up, and follow it instead of improvising.
Skills defer to this file and to `docs/QA.md`; they never override them.

| Situation | Skill |
|-----------|-------|
| New brief, meeting notes, or research to turn into a PRD | `brief-to-prd` |
| A PRD exists and needs a readiness review, JTBDs, slices, a Phase Map, or tracker epics | `discovery-slice` |
| Starting implementation, need the quality loop, a QA charter, an independent check, or the final gate | `testing-with-ai` |
| Ready to open a PR / MR | `pr-checklist` |

Typical order for a feature: `brief-to-prd` -> `discovery-slice` -> `testing-with-ai` -> `pr-checklist`.
Not every task needs every skill: a small fix usually needs only the last two.

<!-- TODO(fill): Issue tracker for this project (GitHub Issues by default; GitLab/Linear if used)
     and its identifier, e.g. `org/repo`. Also record it in CONTRIBUTING.md ("Issues and labels").
     Write N/A if there is no tracker. The skills read it from there. -->

---

## 10. Quick Reference

| Action | Check |
|--------|-------|
| Start working | Read `docs/STATUS.md`, `docs/LESSONS.md`, `docs/QA.md` (§1) |
| Setup, run, validate, branch, review | `CONTRIBUTING.md` |
| Before commit | Reasoning log in the message (§3) |
| Before push | Self-check loop (`docs/QA.md`), `bash scripts/agent-lint.sh`, then a STATUS handoff record (§4, §5) |
| Before opening a PR | `pr-checklist` skill |
| After a reusable correction | New `noted` entry in `docs/LESSONS.md` (§6) |
| Need a workflow (PRD, slicing, QA loop, PR) | Load the matching skill (§9) |
