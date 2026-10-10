---
name: pr-checklist
description: "Pre-PR checklist and pull/merge request creation. Use before opening any pull request or merge request. Triggers: 'ready for a PR', 'open a PR', 'open an MR', 'ready to merge', or when development on a task is complete and needs to ship. Makes sure the build is green, acceptance criteria are met, and the PR is formatted before review."
---

# PR Checklist

Run this after the `testing-with-ai` skill and before opening the PR. Branch naming, review rules, and merge strategy are defined in `CONTRIBUTING.md`; this skill does not restate them.

Never mark the PR ready, approve it, or merge it yourself. That is the human's decision.

## Step 1 - The build must be green

Run the build and the other final-gate commands from `CONTRIBUTING.md` -> Validation (`docs/QA.md` §4, check 5). If you already ran the final gate for this exact change in the `testing-with-ai` skill, do not run it again. If anything fails, fix it first. Do not open the PR with a red build.

## Step 2 - Sanity review against the acceptance criteria

Review the change against the task's acceptance criteria. Use a subagent or a fresh session if your tool supports it; otherwise do a separate, deliberate pass with the criteria open.

```
Do a sanity review for [issue or task]. Read its acceptance criteria, then
check whether each one is met. Are any edge cases missed?
```

For critical business logic, write a unit test before opening the PR. If the review finds gaps, fix them before continuing.

## Step 3 - Prepare the PR

Write the title and description, then **confirm with the human before opening**.

- **Title:** follow `CONTRIBUTING.md`. The default matches the commit format in `AGENTS.md` §3: `<type>: <short summary>`.
- **Description:** if the repository has a PR template (`.github/PULL_REQUEST_TEMPLATE.md` or the host's equivalent), fill that in. Otherwise use `references/pr-template.md`.
- Include at least one concrete verification step.
- Include the evidence block from `docs/QA.md` §6, including what was **not** verified.
- Link the issue at the bottom (`Closes #123` on GitHub). If the project has no tracker, write `N/A`.
- Keep the PR small and focused: one unit of work.

## Step 4 - Before you hand it over

- [ ] `git diff --check` is clean, and the diff has no secrets, generated files, or unrelated changes
- [ ] `docs/STATUS.md` has its handoff record (`AGENTS.md` §5)
- [ ] A reusable correction, if any, is a `noted` entry in `docs/LESSONS.md` (`AGENTS.md` §6)
- [ ] The description says what was verified and what was not

Merge strategy (squash or not, delete-branch default) comes from `CONTRIBUTING.md`. When squashing, write the message as if the next engineer reading `git log` needs to understand the change with no other context: what changed and why, not a list of files.
