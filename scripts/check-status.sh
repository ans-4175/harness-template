#!/usr/bin/env bash
# Deterministic STATUS.md gate (no AI) — single source of truth for the status check.
# Used by scripts/agent-lint.sh (Phase 3) and .claude/hooks/pre-push-guard.sh.
#
# Exit 0 = OK to push.
# Exit 1 = code changes present but no STATUS file is part of this push → you MUST
#          add a handoff record before pushing (AGENTS.md §5).
#
# "STATUS file" = docs/STATUS.md, or docs/status/<domain>.md in per-domain mode.
#
# Fails OPEN if git is unavailable / not a repo (exits 0 rather than blocking work).
set -uo pipefail

MAIN_BRANCH="{{MAIN_BRANCH}}"

command -v git >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

# Files in this push: committed on the branch vs main, plus staged + unstaged.
base=$(git merge-base "$MAIN_BRANCH" HEAD 2>/dev/null || true)
if [[ -n "$base" ]]; then
  changed=$(git diff --name-only "$base" HEAD; git diff --name-only HEAD; git diff --cached --name-only)
else
  changed=$(git diff --name-only HEAD; git diff --cached --name-only)
fi
changed=$(printf '%s\n' "$changed" | sed '/^$/d' | sort -u)

# A STATUS file already part of this push? All good. Templates (_TEMPLATE.md) don't count.
if printf '%s\n' "$changed" | grep -Eq '^docs/(STATUS\.md|status/[^/_][^/]*\.md)$'; then
  echo "PASS: a STATUS file is updated and part of this push."
  exit 0
fi

# Any meaningful code change? (exclude docs, markdown, scripts, .agents, .claude, .pi, .github,
# config/meta, lockfiles) — all of these are template infrastructure, not project code.
code=$(printf '%s\n' "$changed" | grep -Ev \
  '(^docs/|\.md$|^scripts/|^\.agents/|^\.claude/|^\.pi/|^\.github/|(^|/)(\.gitignore|\.gitattributes|\.editorconfig|LICENSE)$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|go\.sum|composer\.lock|poetry\.lock|Gemfile\.lock)$)' || true)

if [[ -z "$code" ]]; then
  echo "PASS: no code changes requiring a STATUS.md entry."
  exit 0
fi

{
  echo "WARNING: docs/STATUS.md must be updated before pushing."
  echo "Code changes are present but no STATUS file (docs/STATUS.md or docs/status/<domain>.md) is part of this push."
  echo "→ Add a handoff record (see AGENTS.md §5), stage/commit it, then retry."
  echo "Changed code files:"
  printf '%s\n' "$code" | sed 's/^/  - /'
} >&2
exit 1
