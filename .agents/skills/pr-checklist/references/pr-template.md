# PR Template

Use this only when the repository has no PR template of its own.

## Title

Follow `CONTRIBUTING.md`. The default is the commit format from `AGENTS.md` §3:

```
<type>: <short summary>
```

Lowercase, no trailing period. Examples:

```
feat: add lead-time indicator and last-activity sort to the deal list
fix: handle session expiry on the auth refresh path
docs: describe the local setup in CONTRIBUTING
```

## Description

```markdown
## What changed
[1-3 sentences summarizing the change and why]

## How to test
[Concrete steps to verify the happy path]
1. Open [page / endpoint]
2. [do X]
3. [Y should be visible / should happen]

## Evidence
Risk tier:         [low | normal | high]
Behaviour:         [behaviour or acceptance criteria that changed]
Automated tests:   [command run and result]
Fixture:           [scenario, if used]
Independent check: [PASS | FAIL | BLOCKED | N/A], [environment], [evidence]
Human gate:        [done by whom | not required for this tier]
Not verified:      [untested behaviour, remaining risk, or "none"]

## Issue
Closes #[number]   (or "N/A")
```

## Full example

```markdown
## What changed
Adds a lead-time indicator to the deal list. Each deal card now shows a badge
with the days since its last update: yellow after 3 days, red after 7.

## How to test
1. Open /deals
2. Check that a lead-time badge appears on every card
3. A deal last updated more than 7 days ago must show a red badge
4. A new deal (under 3 days) must show no badge

## Evidence
Risk tier:         normal
Behaviour:         badge colour thresholds at 3 and 7 days
Automated tests:   `npm test -- deals` -> 14 passed
Fixture:           deals aged 1, 4, and 9 days (seed: deals-aging)
Independent check: PASS, local, snapshots of all three states
Human gate:        done by the reviewer (badge copy and colour)
Not verified:      behaviour with more than 500 deals

## Issue
Closes #312
```

The issue reference format follows the tracker: `#312` on GitHub or GitLab.
