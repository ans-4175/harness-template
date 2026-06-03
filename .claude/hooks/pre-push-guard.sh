#!/usr/bin/env bash
# PreToolUse(Bash) guard — blocks `git push` when docs/STATUS.md must be updated.
# Delegates the actual check to scripts/check-status.sh (single source of truth).
# Fails OPEN: if jq / the check script aren't available, the push proceeds.
set -uo pipefail

# The command Claude is about to run arrives as JSON on stdin.
payload=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Only act on a real `git push`.
case "$cmd" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

proj="${CLAUDE_PROJECT_DIR:-.}"
check="$proj/scripts/check-status.sh"
[[ -x "$check" ]] || exit 0   # fail open if the deterministic check isn't present

# Exit 1 from the check = STATUS.md update required → block the push (exit 2).
if ! reason=$("$check" 2>&1); then
  echo "$reason" >&2
  exit 2
fi
exit 0
