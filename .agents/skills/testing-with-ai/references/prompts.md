# Prompt Templates - Testing with AI

Copy and paste. Fill the `[...]` parts for the task. These prompts assume the rules in `docs/QA.md`.

## Start the quality loop (implementing agent)

```
Do [task or brief] with the quality loop in docs/QA.md.

Read the available context. State the main behaviour and the expected output.
Do not wait for a complete charter or fixtures to start. Write down important
assumptions. Implement in small steps and run the relevant automated tests
while coding. Add or update tests for every changed behaviour. Prepare
fixtures only when the scenario needs them.

When the implementation is stable, send a handoff containing: the behaviour,
the available acceptance criteria, the fixtures, a short QA charter, the
passing test commands, and any test limits. Do not run the full build until
the final gate.
```

## Write the charter while developing

```
From the task and the current implementation, write a short QA charter.
Do not make it a blocker. Include only: the main behaviour, the happy path,
the relevant non-happy states, the fixture or QA account, and the risks to
check. Mark the parts that are still assumptions.
```

## Final technical gate

```
The change is stable. Run the final technical gate for the affected app:
the relevant test suite, then lint, then build, once. Do not change scope.
Report the commands, the results, and the remaining limits so they can go
into the PR evidence block (docs/QA.md section 6).
```

## Independent QA agent

```
Act as an independent QA agent for [task].

Inputs you may use:
- Acceptance criteria: [paste or reference]
- Charter: [paste]
- Fixtures and QA accounts: [scenario names, no credentials]
- Environment: [local / QA / staging URL]

Do not judge from the implementation's explanation. Test the behaviour a
user can see. Start with navigation, snapshots, and any screenshots needed.
Check the happy path and the non-happy states in the charter. Before logging
in, clicking, filling a form, choosing an option, or submitting, state the
target, the action, and the expected outcome, and ask for explicit approval,
unless that mutation scope was already approved.

End with PASS, FAIL, or BLOCKED, plus the steps to reproduce, the evidence,
actual vs expected, and the limits of the test.
```

How the QA agent works after receiving that prompt:

1. Read the charter: main behaviour, positive scenarios, non-happy states, fixtures, the approved action limits.
2. Prepare conditions: run or verify fixtures, decide the target environment and the QA account.
3. Observe first: navigation, accessibility snapshot, screenshots (read-only).
4. Interact within scope: logging in, filling forms, and submitting are mutating, so get explicit approval first unless already approved.
5. Test the happy path and the relevant non-happy states (empty, error, loading, validation, permission, data edge cases).
6. Record the result: actual vs expected, steps, snapshots or screenshots, reproducible failures.

## QA handoff format

```
Environment:        [local / QA / staging]
Fixtures/accounts:  [scenario names, no credentials]
Charter:            [behaviour checked]
Result:             PASS / FAIL / BLOCKED
Evidence:           [steps, snapshot or screenshot]
Findings/limits:    [actual vs expected, or what could not be tested]
```
