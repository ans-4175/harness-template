# {{PROJECT_NAME}} QA & Self-Check Loop

How an agent proves a change works **before** handing it off. Core rule: *writing code fast is
not evidence that it is correct.* Every "done" claim needs evidence someone else can repeat
(a test, a command, a fixture, a recorded check).

Used by `AGENTS.md` §1 (read first) and §8 (definition of done). Commands live in
`CONTRIBUTING.md` → Validation; this file says **when** and **how deep**.

> **Filling this file:** every `TODO(fill)` is a placeholder. Discover the answer from the repo
> first (test config, CI, scripts, existing tests) and write only what you verified by running
> it. If a section does not apply (e.g. no UI, so no browser check), write `N/A` and say why.

---

## 1. The loop

```
understand → implement in small units → run the relevant checks → read the result
     ↑                                                                  │
     └────────── fix, then re-run ONLY what the fix affects ◄───────────┘
                                   │ all green
                                   ▼
        independent check (if tier requires) → human gate (if tier requires)
                                   ▼
                  final technical gate (once) → evidence block → hand off
```

1. **Understand the behaviour.** From the issue, acceptance criteria, or brief: who is affected, the main behaviour, the expected output. Write down assumptions explicitly instead of assuming silently. Ask only if an assumption is blocking.
2. **Implement in small units.** Add or update tests for every changed behaviour or business rule, and run them repeatedly while coding, not once at the end. If a test is not feasible, record the untested behaviour, why, the remaining risk, and what evidence you used instead. Never skip a test silently.
3. **Read the result honestly.** A failing check is information, not an obstacle. A passing run after retries is not green: see §5.
4. **Re-run narrowly.** After a fix, re-run only the affected tests or checks. Save the full gate for step 5.
5. **Final technical gate: once, right before the push** (§4). Not on every iteration.

**Stop conditions.**
- The same approach failed twice: change the approach, do not try it a third time.
- You lack credentials, an account, or access: stop and ask. Do not improvise.
- A check can only be passed by weakening it (skipping a test, lowering a threshold): stop and report instead.

---

## 2. Risk tier

A **human** sets the tier when the work is planned and may raise it later. Agents do not lower it.

| Tier | Typical examples | Minimum evidence |
|------|------------------|------------------|
| Low | Copy, styling, internal refactor with no behaviour change | Affected tests pass. If UI changed, still do a visual check. |
| Normal | Isolated feature or behaviour change | Relevant tests, fixtures where needed, independent check of the happy path and relevant non-happy states. |
| High | Costly if wrong (money, data loss, security, migrations) | Normal evidence, plus the extra review the human owner specifies. |

<!-- TODO(fill): Replace the examples with this project's real high-risk areas (e.g. payments,
     permissions, data migration, public API contracts). Delete this block if the three generic
     tiers are enough. -->

---

## 3. Environments, accounts, and fixtures

<!-- TODO(fill): Where a check may run and what it may touch. Fill from CONTRIBUTING.md and
     config; do not guess. -->

| Environment | Allowed for | Notes |
|-------------|-------------|-------|
| `<local>` | Default for all checks | `<how to start it; ports>` |
| `<staging / shared dev>` | `<only with fixtures / needs approval / not allowed>` | `<what is shared; what must not be mutated>` |
| `<production>` | **Never**, unless the human owner decides explicitly | |

**Fixtures** are data or conditions created on purpose so a scenario can be repeated with the same result. Rules:

- Never run against production.
- Idempotent: re-running does not duplicate data.
- Fixed, predictable identifiers, statuses, dates, roles, relations; names that say what they prove.
- QA accounts and non-sensitive data only. No credentials or sensitive data in commits, docs, screenshots, or logs.
- Just enough data for the scenario under test.
- Cover as relevant: normal, empty, restricted (permissions), edge case.

<!-- TODO(fill): Where fixtures/seeds live and the command that loads them. Where QA credentials
     come from (name the variable or file, never the value). Delete if no fixtures are needed. -->

---

## 4. Checks, in order

Each project fills the commands; the order and intent stay.

| # | Check | Command / how | When |
|---|-------|---------------|------|
| 1 | Focused automated tests for the touched flow | <!-- TODO(fill) --> `{{TEST_CMD}}` (subset) | Repeatedly while coding |
| 2 | Lint / format on changed files | <!-- TODO(fill) --> `{{LINT_CMD}}` | Before the independent check |
| 3 | Independent check of the real behaviour | See "Independent check" below | Per risk tier |
| 4 | Human gate | A person tries what assertions cannot judge | Per risk tier |
| 5 | **Final technical gate**: relevant tests → lint → build | `{{TEST_CMD}}`, `{{LINT_CMD}}`, `{{BUILD_CMD}}` | **Once**, right before the push |

Final-gate hygiene: run it for the affected app or package only. Do not build while that app's
dev server is running, and do not run two builds of the same app in parallel.

<!-- TODO(fill): Slow or costly gates (full suite, e2e): typical duration, whether required or
     opt-in, how to run them in the background. Known-red tests on the integration branch go in
     docs/STATUS.md, not here. -->

### Independent check

Best done by a **fresh agent session** that works from the acceptance criteria, the charter, the
fixtures, and the target environment, **not** from the implementer's assumptions.

<!-- TODO(fill): The tool and method used for this project: browser automation, API client,
     CLI script, or "manual". Write N/A if the project has no runtime behaviour to exercise. -->

Rules:

- **Observe first** (navigate, read, snapshot). This is read-only.
- Before any mutating action (log in, fill a form, submit, write data), state the target and the expected outcome, and get explicit approval unless that scope was already approved.
- Default to local or QA with fixtures. Production only by explicit human decision.
- QA credentials come from the secret store or env file. Never print, screenshot, or commit them.
- End with **PASS / FAIL / BLOCKED**, the steps to reproduce, the evidence, actual vs expected, and the limits of the check.
- On a mismatch: the implementing agent fixes it, then re-runs **only** the affected checks.

### Charter (short, not a blocker)

For a normal or high-tier change, write a few lines so a correct result can be told apart from
one that only looks correct. Mark assumptions.

```md
Behaviour:        <main behaviour and expected output>
Happy path:       <steps>
Non-happy states: <empty, error, permission, boundary values that matter>
Fixture/account:  <what to use>
Risks to check:   <what could silently go wrong>
```

### Human gate

A person checks what assertions cannot: interaction feel, clarity of the UI, quality of copy,
manual scenarios that matter for this change. If the human gate changes code, re-run the affected
tests and independent check before the final gate.

---

## 5. When a check fails or a bug escapes

- **Flaky is not green.** A test that passes only after a retry is a finding: record the flakiness, find the cause, then fix it, isolate it, or stop using it as a gate until reliable.
- **Do not only patch.** When a bug reaches QA, staging, or production, ask:
  - Which behaviour or assumption was wrong?
  - Do the acceptance criteria or the charter need to be clearer?
  - Which automated test, fixture, or hardening case is missing?
  - Was the gate wrong for this risk?
- Add a **regression test or fixture**, not just a code fix.
- If the answer is a rule that applies beyond this one flow, add a `noted` entry to `docs/LESSONS.md` (`AGENTS.md` §6). If it is too specific to generalize, leave the ledger unchanged.

---

## 6. Evidence block

Paste this into the PR/MR description and mirror the key line in the STATUS handoff record.
Keep it short: enough for the next reviewer or agent to know what was tested, under what
conditions, and what is still unknown.

```md
Risk tier:       <low | normal | high>
Behaviour:       <behaviour or acceptance criteria that changed>
Automated tests: <command run and result>
Fixture:         <scenario, if used>
Independent check: <PASS | FAIL | BLOCKED | N/A>, <environment>, <evidence>
Human gate:      <done by whom | not required for this tier>
Not verified:    <untested behaviour, remaining risk, or "none">
```

**Before merge, a human confirms:**

1. Every important behaviour in the acceptance criteria has enough evidence for the tier.
2. The independent check passed, or it was blocked and the risk was explicitly accepted.
3. The human gate was done where judgement was needed.
4. Limits and risk decisions are written in the PR/MR or tracker.
5. For high tier, the extra review is finished.

**After deploy:** merging and deploying do not prove the feature works for users. Verify the main
flow in the environment the change reached, using fixtures or QA accounts where available.

<!-- TODO(fill): Rollout policy for this project (feature flags, staged rollout, monitoring tool,
     rollback steps). Delete if not applicable. -->
