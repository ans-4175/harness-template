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

Once `grep` above returns nothing, this section is done — delete it and continue.

---

## 1. Deploy — Orchestration & Setup

This section is the **universal deploy orchestrator**. Each platform's specifics live in
its skill file (see §6). This section rules what to do in what order.

### 1.1 Auto-detect deploy platform

On first session for a repo (or when deploy config is missing), run the detection checklist
in order. Stop at the first match:

| # | Check | If found → Platform |
|---|-------|---------------------|
| 1 | `wrangler.toml` or `wrangler.jsonc` exists | **Cloudflare** → load `cloudflare-deploy` skill |
| 2 | `vercel.json` exists OR `"vercel"` in `package.json` scripts | **Vercel** → load `vercel-deploy` skill |
| 3 | `fly.toml` exists | **Fly.io** → load `fly-deploy` skill |
| 4 | `netlify.toml` exists OR `"netlify"` in `package.json` scripts | **Netlify** → load `netlify-deploy` skill |
| 5 | `Dockerfile` exists | **Docker** → load `docker-deploy` skill |

Once detected, read the skill file (`.agents/skills/<name>/SKILL.md`) completely.

### 1.2 If no platform detected

Propose **Cloudflare** as the default (free tier, simple, no credit card for Workers/Pages).
Guide the user:

1. "This project has no deploy setup. I recommend **Cloudflare** — free tier, no credit card needed for Workers & Pages. Want me to set it up?"
2. If yes → load `cloudflare-deploy` skill and follow its setup flow.
3. If user picks something else → load the corresponding skill.

### 1.3 Deploy command

Once a platform is configured, set `{{DEPLOY_CMD}}` to whatever the platform skill says
in its "Deploy" section.

---

### 1.4 Universal Pre-Deploy Checklist

**Every deploy — regardless of platform — must pass this gate.** If any step fails, stop
and tell the user what to fix.

| Step | Check | How |
|------|-------|-----|
| 1 | **Branch** | Are we on `{{MAIN_BRANCH}}`? `git branch --show-current` |
| 2 | **Build** | `{{BUILD_CMD}}` passes with 0 errors |
| 3 | **Credentials** | Run the platform's auth-check command (see skill §Credentials) |
| 4 | **Config valid** | Run the platform's config-check command (see skill §Config) |
| 5 | **Secrets ready** | Are all required secrets set? (see skill §Secrets) |
| 6 | **Uncommitted changes** | Warn user if `git status --porcelain` is non-empty |

#### Step 3: Credentials check

Run the platform-specific auth verification. If it fails → guide user to get token/login:

| Platform | Auth check command |
|----------|-------------------|
| Cloudflare | `npx wrangler whoami` |
| Vercel | `vercel whoami` |
| Fly.io | `fly auth whoami` |
| Netlify | `netlify status` |
| Docker | `docker info` (checks daemon) + `docker pull <registry>/hello-world:latest` (silent) |

**If auth fails**: Read the skill's "Setup" section for the exact login flow. Guide the
user step-by-step to create tokens/accounts. Paste the relevant instructions from the skill.

#### Step 4: Config validation

| Platform | Config check |
|----------|-------------|
| Cloudflare | `npx wrangler deploy --dry-run` (or check `wrangler.toml`/`wrangler.jsonc` structure) |
| Vercel | `vercel inspect --scope <team>` (or check `vercel.json` exists & valid JSON) |
| Fly.io | `fly config validate` (or check `fly.toml` exists) |
| Netlify | Check `netlify.toml` exists & valid TOML |
| Docker | Check `Dockerfile` exists & valid syntax (read file, check for obvious errors) |

#### Step 5: Secrets readiness

Check whether the platform's required secrets are set. If missing, guide user:

| Platform | Check secrets |
|----------|--------------|
| Cloudflare | `npx wrangler secret list` — compare with what app needs |
| Vercel | `vercel env ls` — compare with `.env.example` |
| Fly.io | `fly secrets list` — compare with `.env.example` |
| Netlify | `netlify env:list` — compare with `.env.example` |
| Docker | Check `.dockerignore` exists, check no secrets in `Dockerfile` |

**How to know what secrets are needed:**
- Read `.env.example` or `.env` in the repo
- Read framework config (e.g. `wrangler.jsonc` `vars`, `vercel.json` env references)
- Ask user if unclear

---

### 1.5 Deploy Execution

After all 6 pre-deploy steps pass (or user confirms they want to skip specific warnings):

1. **Run the deploy command** from the skill's "Deploy" section
2. **Watch output** — if the command fails, read the error and consult the skill's
   "Common Gotchas" section before retrying
3. **Post-deploy verify** — after successful deploy, run the health check from the
   skill's "Verify" section
4. **Report to user**:
   - Production/preview URL
   - Deployment ID or timestamp
   - Any warnings (e.g. "custom domain not configured yet")

---

### 1.6 Rollback

If deploy failed or user asks to rollback, follow the skill's "Rollback" section.
Report the rolled-back version/URL to the user.

---

## 2. Push & Deploy Rules

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

> **Claude Code users:** this template also ships native integration in `.claude/`.
> Run the lint in-session with `/agent-lint` (or the individual `/check-constants`,
> `/check-simplify` commands) instead of the bash script. A `PreToolUse` hook also
> **blocks `git push`** automatically if you're pushing code without a `docs/STATUS.md`
> update — so you can't forget step 3.

### Deployment
- **Only deploy when the user explicitly asks.** Never deploy on your own initiative.
- When the user requests a deploy:
  1. Verify you are on the `{{MAIN_BRANCH}}` branch
  2. Run `{{BUILD_CMD}}` — must pass with 0 errors
  3. Load the active deploy skill (see §1) and follow its pre-deploy checklist
  4. Deploy: `{{DEPLOY_CMD}}`
  5. Run post-deploy verification (health check, URL confirmation)
- **Do NOT update STATUS.md for deploy.** STATUS.md is a push journal, not a deploy log.

---

## 3. Commit Rules (on `{{MAIN_BRANCH}}`)

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

## 4. STATUS.md Protocol (Mandatory)

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

## 5. Quick Reference

| Action | Check |
|--------|-------|
| Start working | Read `docs/STATUS.md` |
| Detect deploy platform | Run §1.1 checklist |
| Before commit | Write reasoning in commit message |
| Before push | Run `bash scripts/agent-lint.sh` |
| Before deploy (user must ask first) | Verify on `{{MAIN_BRANCH}}` + `{{BUILD_CMD}}` passes + platform pre-deploy checks |

---

## 6. Deploy Skills (load on-demand)

When a deploy platform is detected or the user asks to deploy, load the corresponding
skill from `.agents/skills/`:

| Platform | Skill | When to load |
|----------|-------|--------------|
| Cloudflare Workers & Pages | `cloudflare-deploy` | Auto-detect or user asks |
| Vercel | `vercel-deploy` | Auto-detect or user asks |
| Fly.io | `fly-deploy` | Auto-detect or user asks |
| Netlify | `netlify-deploy` | Auto-detect or user asks |
| Docker (build + push) | `docker-deploy` | Auto-detect or user asks |

**How to use a skill:**
1. Read `.agents/skills/<skill-name>/SKILL.md`
2. Follow the numbered steps in order
3. Each skill covers: detection, setup, config, secrets, build, deploy, verify, rollback
4. If a skill has its own `references/` folder, consult those files for platform-specific
   config templates (e.g. `wrangler.jsonc` examples, `vercel.json` patterns)

---

## 7. Environment

> Fill in the secrets / config this project needs and where each comes from.
> The deploy skill for your platform will tell you which secrets are needed.
> Delete this note once filled.

| Var | Source |
|-----|--------|
| `<EXAMPLE_SECRET>` | `<where it comes from — secret manager, .env, CI variable, ...>` |

---

## 8. Project Conventions

> Optional. Document anything an agent must follow that isn't obvious from the code:
> design system / colors, naming conventions, directory layout, framework gotchas.
> Delete this section if you have nothing project-specific to add.
