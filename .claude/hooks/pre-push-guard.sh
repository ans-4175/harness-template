#!/usr/bin/env bash
# PreToolUse(Bash) guard — blocks `git push` if code changes are being pushed
# without a docs/STATUS.md update. Deterministic mirror of
# scripts/check-status.prompt (no AI call). Fails OPEN: if anything is missing
# (jq, git, main branch), it lets the push through rather than blocking work.
set -uo pipefail

MAIN_BRANCH="{{MAIN_BRANCH}}"

# The command Claude is about to run arrives as JSON on stdin.
payload=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Only act on a real `git push`.
case "$cmd" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

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
  exit 0
fi

# Any meaningful code change? (exclude docs, markdown, scripts, .claude, config/meta, lockfiles)
code=$(printf '%s\n' "$changed" | grep -Ev \
  '(^docs/|\.md$|^scripts/|^\.claude/|(^|/)(\.gitignore|\.gitattributes|\.editorconfig|LICENSE)$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|go\.sum|composer\.lock|poetry\.lock|Gemfile\.lock)$)' || true)

if [[ -n "$code" ]]; then
  {
    echo "Push blocked: code changes detected but docs/STATUS.md is not part of this push."
    echo "Append a push-journal entry to docs/STATUS.md (see AGENTS.md §3), commit it, then push again."
    echo "Changed code files:"
    printf '%s\n' "$code" | sed 's/^/  - /'
  } >&2
  exit 2
fi

exit 0
