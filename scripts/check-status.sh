#!/usr/bin/env bash
# Deterministic STATUS.md gate (no AI) — single source of truth for the status check.
# Used by scripts/agent-lint.sh (Phase 3) and .claude/hooks/pre-push-guard.sh.
#
# Exit 0 = OK to push.
# Exit 1 = code changes present but docs/STATUS.md not part of this push → you MUST
#          update docs/STATUS.md before pushing.
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

# STATUS.md already part of this push? All good.
if printf '%s\n' "$changed" | grep -q 'docs/STATUS\.md'; then
  echo "PASS: docs/STATUS.md is updated and part of this push."
  exit 0
fi

# Any meaningful code change? (exclude docs, markdown, scripts, .claude, .pi, .github,
# config/meta, lockfiles) — all of these are template infrastructure, not project code.
code=$(printf '%s\n' "$changed" | grep -Ev \
  '(^docs/|\.md$|^scripts/|^\.claude/|^\.pi/|^\.github/|(^|/)(\.gitignore|\.gitattributes|\.editorconfig|LICENSE)$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|go\.sum|composer\.lock|poetry\.lock|Gemfile\.lock)$)' || true)

if [[ -z "$code" ]]; then
  echo "PASS: no code changes requiring a STATUS.md entry."
  exit 0
fi

{
  echo "WARNING: docs/STATUS.md must be updated before pushing."
  echo "Code changes are present but docs/STATUS.md is not part of this push."
  echo "→ Append a push-journal entry to docs/STATUS.md (see AGENTS.md §3), stage/commit it, then retry."
  echo "Changed code files:"
  printf '%s\n' "$code" | sed 's/^/  - /'
} >&2
exit 1
