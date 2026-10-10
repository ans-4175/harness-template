# Contributing to {{PROJECT_NAME}}

This file holds the **commands and the workflow**. Rules for agents (what to read, commit
format, STATUS and LESSONS protocol, safety) live in [`AGENTS.md`](AGENTS.md). Do not repeat
them here; link to them.

> **Filling this file:** every `TODO(fill)` block below is a placeholder. Discover the answer
> from the repo first (manifests, CI config, scripts, existing docs, `git log`) and write only
> what you verified by running it. Ask the user for anything the repo cannot tell you. If a
> section does not apply, write `N/A` or delete it. Delete this note when done.

Who may contribute: <!-- TODO(fill): e.g. "Open to everyone" / "Team members only". -->

---

## Local development setup

### Preflight

<!-- TODO(fill): What to check before the first command of a session. One row per check:
     the command, the expected result, and what to do if it fails. Typical rows: runtime
     version, package manager, required ports, container runtime, required CLIs (git host
     CLI), required services. If a script already runs these, name it and keep the table
     short. -->

| Check | Command | Expected | If it fails |
|-------|---------|----------|-------------|
| `<e.g. runtime>` | `<command>` | `<expected>` | `<what to do>` |

### First run

<!-- TODO(fill): The exact commands to install dependencies and run the project locally,
     and how to stop it. Include rough timings if they matter, and anything that looks like
     an error but is harmless. -->

```bash
<install command>
<run command>
```

### Run modes

<!-- TODO(fill): Only if the project can run in more than one way (host vs container, local
     backend vs remote dev). Name each mode, what it needs, and what it is for. State which
     modes touch shared or production services. Delete if there is a single mode. -->

### Shared and production services

<!-- TODO(fill): Which environments an agent must NOT touch without explicit approval, and
     how a local run is kept from reaching them by accident (e.g. config defaults that point
     at a shared host). Delete if the project has no shared environments. -->

---

## Validation

How deep to check, which environments are allowed, and the evidence format are in
[`docs/QA.md`](docs/QA.md). This section holds the **commands** that file refers to.

<!-- TODO(fill): What to run for which kind of change. Keep the project's own commands. -->

| Change | Run |
|--------|-----|
| Every change | `git diff --check`, then review the diff for secrets, generated files, and unrelated edits |
| Source code | `{{LINT_CMD}}` and `{{TEST_CMD}}` (focused subset is fine) |
| Build / dependency / config | `{{BUILD_CMD}}` |
| Docs only | Re-check links, commands, and facts against the tree |

<!-- TODO(fill): Slow or costly gates (full test suite, e2e, visual QA): how long they take,
     whether they are required or opt-in, and how to run them. Known-red tests on the
     integration branch belong in docs/STATUS.md, not here. -->

The **final technical gate** (relevant tests, lint, build) runs once, right before the push.
Per-iteration checks are the focused ones above.

---

## Branches

Default branch: `{{MAIN_BRANCH}}`.

<!-- TODO(fill): Protected branches and who may push to them. Integration vs release branch,
     if they differ. -->

### Branch naming

<!-- TODO(fill): Derive from `git branch -r` and recent history rather than guessing, then
     state one convention. -->

| Prefix | Use for |
|--------|---------|
| `feat/<topic>` | a new feature |
| `fix/<topic>` | a bug fix |
| `chore/<topic>` | tooling, docs, dependencies |

---

## Pull / merge requests

<!-- TODO(fill): Replace "pull request" with "merge request" if the host is GitLab. -->

1. Branch from the up-to-date `{{MAIN_BRANCH}}` (or the integration branch above).
2. Commit in logical chunks. The message format is in `AGENTS.md` §3.
3. Run the checks in **Validation**.
4. Open a pull request using the `pr-checklist` skill. Describe the change, include the evidence block from `docs/QA.md` §6 (what ran and what was **not** verified), and link the issue.
5. Keep it focused: no unrelated commits or formatting. Ask first before a large change.

<!-- TODO(fill): Reviewer assignment, squash and delete-branch defaults, required CI checks,
     and the host CLI preflight (`gh`/`glab`: installed? authenticated? able to read this
     repo?). Never guess which account to use: if unclear, stop and ask. -->

---

## Issues and labels

Issue tracker: **GitHub Issues** (default) <!-- TODO(fill): confirm, or replace with GitLab Issues / Linear / N/A, and add the identifier (e.g. `org/repo`). The `discovery-slice` skill reads this. -->

<!-- TODO(fill): The title convention and the templates in use (`.github/ISSUE_TEMPLATE/` or the
     host's equivalent). If the project has no tracker or no label scheme, write N/A. -->

| Group | Labels |
|-------|--------|
| Type | `<e.g. bug, improvement>` |
| Priority | `<e.g. priority::high>` |
| Workflow | `<e.g. in progress, in review, done>` |

Labels go on issues, not on pull requests, unless the project says otherwise.

---

## Releasing

<!-- TODO(fill): Who releases, from which branch, how versions are numbered, which files carry
     the version, and where the changelog goes. Agents should not bump versions or tag unless
     the task is explicitly a release. -->
