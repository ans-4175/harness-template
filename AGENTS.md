# Agent Rules — {{PROJECT_NAME}}

> **Read this before doing ANY work.** Read `docs/STATUS.md` first to understand current state.

---

## 0. First-Time Setup (do this before anything else)

This file was created from a template. Before following any rule below, check whether
template placeholders are still present:

```bash
grep -rno '{{[A-Z_]*}}' . --exclude-dir=.git
```

**If any `{{...}}` placeholder is still found**, do NOT proceed with the task yet.
Ask the user for the correct value of each remaining placeholder, then replace every
occurrence across all files. The placeholders and what they mean:

| Placeholder | Ask the user for | Example |
|-------------|------------------|---------|
| `{{PROJECT_NAME}}` | The project's name | `Acme API` |
| `{{MAIN_BRANCH}}` | The default branch | `main` |
| `{{BUILD_CMD}}` | Command that builds / typechecks | `npm run build`, `cargo build` |
| `{{LINT_CMD}}` | Command that lints (optional) | `npm run lint`, `ruff check .` |
| `{{DEPLOY_CMD}}` | Command that deploys | `npm run deploy`, `flyctl deploy` |

Once `grep` above returns nothing, this section is done — delete it and continue.

---

## 1. Push & Deploy Rules

### Before Pushing to Remote
When the user asks to push (any branch):

1. Run agent lint:
```bash
bash scripts/agent-lint.sh
```

This runs 3 phases **sequentially**:
1. **Magic strings/numbers audit** — read-only, reports literals that should be named constants
2. **Simplify changed files** — auto-fixes readability issues on changed files, then verifies the build (`{{BUILD_CMD}}`)
3. **STATUS.md update check** — verifies that `docs/STATUS.md` is staged with a journal entry for this push

After phases 1 & 2 pass, **update `docs/STATUS.md`** with a new journal entry and stage it, so phase 3 passes.

If all phases pass → push.

### Deployment
- **Only deploy when the user explicitly asks.** Never deploy on your own initiative.
- When the user requests a deploy:
  1. Verify you are on the `{{MAIN_BRANCH}}` branch
  2. Run `{{BUILD_CMD}}` — must pass with 0 errors
  3. Deploy: `{{DEPLOY_CMD}}`
- **Do NOT update STATUS.md for deploy.** STATUS.md is a push journal, not a deploy log.

---

## 2. Commit Rules (on `{{MAIN_BRANCH}}`)

Every commit to `{{MAIN_BRANCH}}` MUST include a reasoning log. This is **not** a git log — it's a thinking trail.

### Format in commit message:

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

---

## 3. STATUS.md Protocol (Mandatory)

### What STATUS.md tracks
`docs/STATUS.md` is a **push journal** — it records what was pushed to remote and why.
It is NOT a commit log or deploy log.

### When to update
- **After every push to remote (any branch)** → append a new entry
- **Local commits (not pushed)** → do NOT update STATUS.md
- **Deploy** → do NOT update STATUS.md (deploy is just a push that happens to trigger a deploy)

### Before working (always):
1. Read `docs/STATUS.md` completely
2. Understand what the last agent pushed and why
3. Note any "What next" or "Open questions" entries

### After pushing:
1. Append a new entry to `docs/STATUS.md` following the journal format in that file
2. Update the Quick Status table (Branch, Last Activity)
3. If the journal is getting long, check if truncation is needed
4. Then commit

### Never:
- Skip reading STATUS.md before working
- Push without updating STATUS.md

---

## 4. Quick Reference

| Action | Check |
|--------|-------|
| Start working | Read `docs/STATUS.md` |
| Before commit | Write reasoning in commit message |
| Before push | Run `bash scripts/agent-lint.sh` |
| Before deploy (user must ask first) | Verify on `{{MAIN_BRANCH}}` branch + `{{BUILD_CMD}}` passes |

---

## 5. Environment

> Fill in the secrets / config this project needs and where each comes from.
> Delete this note once filled.

| Var | Source |
|-----|--------|
| `<EXAMPLE_SECRET>` | `<where it comes from — secret manager, .env, CI variable, ...>` |

---

## 6. Project Conventions

> Optional. Document anything an agent must follow that isn't obvious from the code:
> design system / colors, naming conventions, directory layout, framework gotchas.
> Delete this section if you have nothing project-specific to add.
