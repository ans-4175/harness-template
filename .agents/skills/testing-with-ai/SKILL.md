---
name: testing-with-ai
description: "Run the self-check quality loop while implementing a change: automated tests while coding, fixtures, a QA charter, an independent check, a human gate, and one final technical gate before the push. Use when starting implementation of a task, preparing a QA handoff, or right before opening a PR. Triggers: 'quality loop', 'start this task', 'write a QA charter', 'hand off to QA', 'final technical gate', 'why did this bug slip through'."
---

# Testing with AI

This skill **runs** the loop. The rules, the risk tiers, the environment limits, and the evidence format live in [`docs/QA.md`](../../../docs/QA.md). Read that file first and follow it; do not restate or override it here.

Core idea: writing code fast is not evidence that it is correct. Every "done" needs evidence someone else can repeat.

The loop runs **inside** one task (an issue, a ticket, or a request from the user) and ends right before the `pr-checklist` skill.

---

## Step 0 - Pick the entry point

Do not always start from the beginning.

| Situation | Start at |
|---|---|
| A new task or brief | Step 1 |
| Implementation is stable and needs an independent check | Step 3 |
| A charter exists and the independent check should run | Step 4 |
| All checks and gates are done and you are about to push | Step 5 |
| A bug escaped to QA, staging, or production | Step 6 |

Do not wait for a complete charter or fixtures before starting. If the behaviour is clear enough, execute it. Write down important assumptions and continue, and ask only if an assumption is blocking.

## Step 1 - Understand the behaviour and the tier

Take the behaviour from the acceptance criteria, or from the brief if there are none. You need at minimum: who is affected, the main behaviour, and the expected positive output.

Read the risk tier in `docs/QA.md` §2. A human sets it; if none is set, ask for it when the change is not clearly low risk. Record assumptions explicitly.

## Step 2 - Implement with tests

Work in small units. Every changed behaviour or business rule adds or updates a relevant test, run repeatedly while coding (`docs/QA.md` §1 and §4, check 1).

If a test is not feasible for some part, record the untested behaviour, why, the remaining risk, and the alternative evidence. Never skip a test silently.

Fixtures, if the scenario needs them: follow `docs/QA.md` §3.

## Step 3 - Charter and handoff

For a normal or high tier, write a short charter (format: `docs/QA.md` §4; prompt: `references/prompts.md`). It is not a blocker. It only has to tell a correct result from one that merely looks correct. Mark assumptions.

Hand off to the independent check, ideally a fresh agent session with no implementation explanation. The handoff carries: the behaviour, the acceptance criteria, the fixtures, the charter, the passing test commands, and the known limits.

## Step 4 - Independent check and human gate

Run the independent check as described in `docs/QA.md` §4 ("Independent check") using the tool that file names. The checker works from the acceptance criteria, charter, fixtures, and target environment, not from the implementer's assumptions. Use the QA-agent prompt in `references/prompts.md`.

Rules that matter most: observe first (read-only); get explicit approval before any mutating action; default to local or QA with fixtures; never print or commit credentials; finish with PASS, FAIL, or BLOCKED plus steps to reproduce, evidence, actual vs expected, and limits.

On a mismatch, the implementing agent fixes it and re-runs **only** the affected checks.

Then the human gate, if the tier needs one (`docs/QA.md` §4). If it changes code, re-run the affected tests and independent check first.

## Step 5 - Final technical gate (once, before the push)

Run it once, right before the push, for the affected app or package only: relevant tests, then lint, then build. The commands are in `CONTRIBUTING.md` -> Validation. Do not repeat it while iterating, do not build while that app's dev server is running, and do not run two builds of the same app in parallel.

Then fill the evidence block (`docs/QA.md` §6) and continue to the `pr-checklist` skill.

## Step 6 - When a check fails or a bug escapes

Follow `docs/QA.md` §5. In short: a flaky test is not green; do not only patch the code; add a regression test, fixture, or hardening case; and if the answer is a rule that applies beyond this flow, add a `noted` entry to `docs/LESSONS.md` (`AGENTS.md` §6).

---

## Human collaboration points

- **Step 1**: confirm an assumption if it is blocking, and the risk tier if unclear
- **Step 4**: explicit approval before any mutating action in the independent check; the human gate itself
- **After Step 5, before merge**: a human confirms the evidence is enough for the tier (checklist in `docs/QA.md` §6)
