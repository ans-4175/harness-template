# AI Harness Template

A drop-in baseline for AI coding agents: **how to work in a repo** (read first, commit,
push, hand off) and **how the repo remembers** (current state and reusable lessons).
Copy it into any project and fill the placeholders once.

It is language-neutral. Build, lint, and test commands are placeholders.

## What you get

| File | Purpose |
|------|---------|
| `AGENTS.md` | The rules: read-first list, commit format, push flow, STATUS and LESSONS protocols, safety, definition of done. `CLAUDE.md` is a symlink to it. |
| `CONTRIBUTING.md` | Setup, run, validation, branch, PR, issue, and release workflow. Ships as **placeholders** for the agent to fill from the repo. |
| `docs/STATUS.md` | Current snapshot, blockers, last verified, decisions, and one handoff record per push. |
| `docs/LESSONS.md` | Append-only ledger of reusable corrections. States: `noted` (agent) and `verified` (human). |
| `docs/QA.md` | Self-check loop: risk tier, fixtures, checks in order, independent check, evidence block. Ships as **placeholders**. |
| `.agents/skills/` | Four workflow skills (`brief-to-prd`, `discovery-slice`, `testing-with-ai`, `pr-checklist`), linked into `.claude/skills/`. |
| `docs/discovery/` | Drop zone for briefs, notes, and research that `brief-to-prd` reads. |
| `docs/DOMAINS.md` + `docs/status/` + `docs/lessons/` | Optional per-domain split for large repos. Off while the map is empty. |
| `scripts/agent-lint.sh` | Pre-push lint, 3 phases: constants audit (AI), simplify (AI), STATUS gate (deterministic). |
| `.claude/`, `.pi/` | Native integration: `/agent-lint` commands, a push hook that enforces the STATUS gate, and a commit-format guard. |
| `.github/` | Issue and PR templates. |

## Layout

```
.
├── AGENTS.md                  # agent rules (read first)
├── CLAUDE.md -> AGENTS.md     # symlink
├── CONTRIBUTING.md            # workflow placeholders
├── docs/
│   ├── STATUS.md              # snapshot + handoff records
│   ├── LESSONS.md             # noted / verified ledger
│   ├── QA.md                  # self-check loop + evidence block
│   ├── discovery/README.md    # where discovery materials go
│   ├── DOMAINS.md             # per-domain map (empty = off)
│   ├── status/_TEMPLATE.md    # per-domain status template
│   └── lessons/_TEMPLATE.md   # per-domain lessons template
├── .agents/skills/            # brief-to-prd, discovery-slice, testing-with-ai, pr-checklist
├── scripts/
│   ├── agent-lint.sh          # orchestrator
│   ├── check-constants.prompt # phase 1 (AI, read-only)
│   ├── check-simplify.prompt  # phase 2 (AI, edits changed files)
│   └── check-status.sh        # phase 3 (deterministic; exit 1 = update STATUS)
├── .claude/                   # settings.json, hooks/, commands/, skills/ (symlinks to .agents/skills)
├── .pi/extensions/            # pre-push-guard.ts, commit-msg-guard.ts
└── .github/                   # issue + PR templates
```

## Setup

1. **Copy** the files into your project root (keep the layout).
2. **Let the agent fill it.** Start an agent in the project; `AGENTS.md` §0 tells it to find the unfilled placeholders and complete them. There are two kinds:

   | Kind | Example | Filled by |
   |------|---------|-----------|
   | Value | `{{PROJECT_NAME}}` | Replace everywhere. Ask the user. |
   | Section | `<!-- TODO(fill): ... -->` | The agent discovers it from the repo and writes only what it verified. |

   | Value | Meaning | Example |
   |-------|---------|---------|
   | `{{PROJECT_NAME}}` | Project name | `Acme API` |
   | `{{MAIN_BRANCH}}` | Default / integration branch | `main` |
   | `{{BUILD_CMD}}` | Build or typecheck | `npm run build` |
   | `{{LINT_CMD}}` | Lint (optional) | `npm run lint` |
   | `{{TEST_CMD}}` | Tests (optional) | `npm test` |

   Or do the values by hand (macOS `sed`; drop the `''` on Linux):
   ```bash
   grep -rlE '\{\{[A-Z_]+\}\}' . --exclude-dir=.git | while read -r f; do
     sed -i '' -e 's/{{PROJECT_NAME}}/Acme API/g' -e 's/{{MAIN_BRANCH}}/main/g' \
       -e 's#{{BUILD_CMD}}#npm run build#g' -e 's#{{LINT_CMD}}#npm run lint#g' \
       -e 's#{{TEST_CMD}}#npm test#g' "$f"
   done
   ```
3. `chmod +x scripts/*.sh .claude/hooks/*.sh`
4. If symlinks did not survive the copy: `ln -sf AGENTS.md CLAUDE.md`, and for each skill `ln -s ../../.agents/skills/<name> .claude/skills/<name>`
5. Install an AI CLI that `agent-lint.sh` can call (it picks the first of `pi`, `claude`, `opencode`). The Claude Code hook needs `jq`.

## How it works

### STATUS: where the repo stands

`docs/STATUS.md` is curated state, not a log. The snapshot sections are edited **in place**; every push adds **one handoff record** (newest first) with evidence and a next step. Files are compacted in place past 1,000 lines, 80 KB, or 100 records, and an unresolved blocker is never dropped.

### LESSONS: what to do differently

`docs/LESSONS.md` is append-only. The test: *would this still help on a different task next month?* If yes, it is a lesson; if it answers "where are we now", it is status.

| State | Set by |
|-------|--------|
| `noted` | The agent, automatically, for every new entry |
| `verified` | A human, only when asked. Agents never promote their own entries |

A corrected entry is never deleted: it gets `Superseded by: <title>`.

### Push flow

`bash scripts/agent-lint.sh` runs three phases in order:

1. **Constants audit** (AI, read-only): literals that should be named constants.
2. **Simplify** (AI, edits changed files only): readability, then verifies `{{BUILD_CMD}}`.
3. **STATUS gate** (deterministic): exit 1 if code changed but `docs/STATUS.md` (or `docs/status/<domain>.md`) is not part of the push.

Every push updates STATUS. Local, unpushed commits do not. In Claude Code the same flow runs as `/agent-lint`, and a `PreToolUse` hook blocks `git push` when phase 3 fails. In Pi, `.pi/extensions/` does the same and also checks the commit format (`AGENTS.md` §3).

### Scale: one file or per domain

Default is one STATUS and one LESSONS file. For a repo with several areas, fill `docs/DOMAINS.md` and create `docs/status/<domain>.md` + `docs/lessons/<domain>.md` from the templates. A change has one primary domain; other domains get a one-line pointer.

### QA: prove it before handing off

`docs/QA.md` is the self-check loop: understand → implement in small units → run relevant checks → fix and re-run only what is affected → independent check and human gate per risk tier → one final technical gate before the push → an evidence block in the PR. It ships as a skeleton; the agent fills commands, environments, and fixtures from the repo.

### Skills: from brief to pull request

| Skill | Does |
|-------|------|
| `brief-to-prd` | Ingests `docs/discovery/`, writes a synthesis, asks at most 5 gap questions, drafts `docs/plans/prd.md` section by section. |
| `discovery-slice` | Checks PRD readiness, extracts JTBDs, finds the thinnest slice per job, writes `docs/plans/phase-map.md`, and optionally creates epics and tasks (GitHub Issues by default). |
| `testing-with-ai` | Runs the loop in `docs/QA.md`: tests while coding, charter, independent check, human gate, one final gate. |
| `pr-checklist` | Green build, sanity review against acceptance criteria, then a PR with the evidence block. Never merges. |

They do not duplicate the core: `testing-with-ai` and `pr-checklist` point to `docs/QA.md`, `CONTRIBUTING.md`, and `AGENTS.md`. The issue tracker is not required; `discovery-slice` stops at the Phase Map when `CONTRIBUTING.md` says `N/A`.

### Starting empty

`docs/STATUS.md` and `docs/LESSONS.md` ship empty. Fill them from values you give the agent, or ask it to explore the repo (`git log`, manifests, CI, docs, `TODO`/`FIXME` comments). It records only what it can point to, with the source, and writes no history or lessons from guesses.

## Customizing

- **Add a skill:** create `.agents/skills/<name>/SKILL.md` (frontmatter `name` and `description`), link it with `ln -s ../../.agents/skills/<name> .claude/skills/<name>`, and add a row to `AGENTS.md` §9.
- **Add or remove a lint phase:** add a `.prompt` file and a `run_prompt` line in `agent-lint.sh`.
- **Change the audit rules:** edit `check-constants.prompt` / `check-simplify.prompt`.
- **Different AI CLI:** extend the detection block at the top of `agent-lint.sh`.
- **Different STATUS rule:** edit `scripts/check-status.sh` only. The Claude hook and the Pi extension both delegate to it.
