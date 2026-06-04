# AI Harness Template

A drop-in set of guardrails and deploy orchestration for AI coding agents working on any project.

**It gives an agent four things:**

1. **`AGENTS.md`** — rules: push/deploy flow, commit reasoning logs, status protocol, and a universal deploy orchestrator.
2. **`scripts/agent-lint.sh`** — a pre-push lint pipeline: two AI review phases (magic-string audit + simplify) plus a deterministic STATUS.md gate.
3. **`docs/STATUS.md`** — a push journal so the next agent (or you) knows what was pushed and why.
4. **`.agents/skills/`** — deploy skills for 5 platforms (Cloudflare, Vercel, Fly.io, Netlify, Docker). Each covers detection, setup, secrets, build, deploy, verify, rollback, and common gotchas.

It is **language-neutral**: build/lint commands are placeholders you fill in once. Deploy platform is auto-detected.

## Layout

```
.
├── AGENTS.md                       # agent rules (read first) — includes deploy orchestration
├── CLAUDE.md -> AGENTS.md          # symlink, so Claude Code agents read the same rules
├── .agents/
│   └── skills/
│       ├── cloudflare-deploy/      # Cloudflare Workers & Pages deploy skill
│       ├── vercel-deploy/          # Vercel deploy skill
│       ├── fly-deploy/             # Fly.io deploy skill
│       ├── netlify-deploy/         # Netlify deploy skill
│       └── docker-deploy/          # Docker build & push skill
├── .claude/
│   ├── settings.json               # PreToolUse hook (committed — team config)
│   ├── hooks/
│   │   └── pre-push-guard.sh       # blocks `git push` if code changes lack STATUS.md update
│   ├── commands/                   # /agent-lint, /check-constants, /check-simplify
│   └── skills/                     # symlinks → .agents/skills/ (Claude Code auto-discovery)
├── docs/
│   └── STATUS.md                   # push journal (seeded, ready to append to)
└── scripts/
    ├── agent-lint.sh               # orchestrator: 2 AI phases + deterministic status gate
    ├── check-constants.prompt      # phase 1 — magic strings/numbers audit (read-only, AI)
    ├── check-simplify.prompt       # phase 2 — simplify changed files, then verify build (AI)
    └── check-status.sh             # phase 3 — deterministic STATUS.md gate (no AI; exit 1 = must update)
```

## Setup

1. **Copy** these files into your project root (keep the `scripts/`, `docs/`, `.agents/`, and `.claude/` layout).
2. **Replace the placeholders** below across all files (a single find/replace per token):

   | Placeholder | Replace with | Example |
   |-------------|-------------|---------|
   | `{{PROJECT_NAME}}` | Your project name | `Acme API` |
   | `{{MAIN_BRANCH}}` | Your default branch | `main` |
   | `{{BUILD_CMD}}` | Command that builds / typechecks | `npm run build`, `cargo build`, `make` |
   | `{{LINT_CMD}}` | Command that lints (optional) | `npm run lint`, `ruff check .` |

   > `{{DEPLOY_CMD}}` is auto-detected by the agent from your platform config — no need to fill it manually.

   Quick one-liner (run from the copied folder, edit the values first):
   ```bash
   grep -rl '{{' . --exclude-dir=.git | while read -r f; do
     sed -i '' \
       -e 's/{{PROJECT_NAME}}/Acme API/g' \
       -e 's/{{MAIN_BRANCH}}/main/g' \
       -e 's#{{BUILD_CMD}}#npm run build#g' \
       -e 's#{{LINT_CMD}}#npm run lint#g' \
       "$f"
   done
   ```
   (Drop the `''` after `-i` on Linux/GNU sed.)

3. **Make the scripts executable:** `chmod +x scripts/*.sh .claude/hooks/*.sh`
4. **Install an AI CLI** the script can call — it auto-detects `pi`, `claude`, or `opencode` (first one found wins).
5. **Recreate the symlink** if your copy method didn't preserve it:
   ```bash
   ln -sf AGENTS.md CLAUDE.md
   ```

## How it works

### Pre-push lint

Run `bash scripts/agent-lint.sh` before pushing. It runs the 3 phases sequentially and streams each phase's output straight to your terminal.

- **Phase 1** (constants) is a read-only AI report.
- **Phase 2** (simplify) is an AI pass that **edits** changed files (simplifications only) and verifies the build.
- **Phase 3** is a deterministic shell gate — `scripts/check-status.sh` — that exits 1 if there are code changes without a `docs/STATUS.md` update, meaning you **must** update STATUS.md before pushing.

### Deploy orchestration

When an agent starts working on a project, it auto-detects the deploy platform:

| Check | Platform |
|-------|----------|
| `wrangler.toml`/`wrangler.jsonc` exists | **Cloudflare** |
| `vercel.json` exists | **Vercel** |
| `fly.toml` exists | **Fly.io** |
| `netlify.toml` exists | **Netlify** |
| `Dockerfile` exists | **Docker** |
| None found | Proposes **Cloudflare** by default |

Before deploying, the agent runs a 6-step universal pre-deploy gate:
1. Branch check (are we on main?)
2. Build verification
3. Credentials check (CLI auth)
4. Config validation
5. Secrets readiness
6. Uncommitted changes warning

After all gates pass, the agent follows the platform-specific deploy skill (build → deploy → verify) and reports the result. Each skill also covers rollback and common gotchas.

### Claude Code integration

The `.claude/` layer runs lint phases natively in-session (no nested CLI):

- **`/agent-lint`** runs all 3 phases natively.
- **`/check-constants`** — magic strings/numbers audit only.
- **`/check-simplify`** — simplify changed files only.
- **Pre-push hook** blocks `git push` if code changes lack a `docs/STATUS.md` update.

Skills are auto-discovered via `.claude/skills/` symlinks. Requires **`jq`** on PATH for the hook.

## Deploy Skills

Each platform has a dedicated skill in `.agents/skills/<platform>/SKILL.md`. Skills cover:

| Section | Contents |
|---------|----------|
| Detection | How to confirm the platform is in use |
| Determine type | Workers vs Pages, static vs serverless, registry detection |
| Pre-deploy checklist | Credentials, config, secrets — what to check and how |
| Setup | CLI install, login, project init, minimal config |
| Secrets & env vars | How to set, list, import, and validate |
| Build | Build commands and auto-detection |
| Deploy | Exact deploy commands for each project type |
| Post-deploy verify | Health check commands, URL reporting |
| Rollback | How to revert a failed deploy |
| Common gotchas | Platform-specific pitfalls and free tier limits |

## Customizing

- **Add a deploy platform:** create a new folder in `.agents/skills/<platform>/` with a `SKILL.md`, symlink it from `.claude/skills/`, and add it to the detection table in `AGENTS.md` §1.1.
- **Add or remove a lint phase:** add another `.prompt` file and a `run_prompt` line in `agent-lint.sh`.
- **Change the audit rules:** the prompts are plain text — edit `check-constants.prompt` / `check-simplify.prompt` to match your conventions.
- **Different AI CLI:** add it to the detection block at the top of `agent-lint.sh`.
