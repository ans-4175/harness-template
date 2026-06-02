#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Resolve AI CLI ---
AGENT_CMD=""
if command -v pi &> /dev/null; then
    AGENT_CMD="pi"
elif command -v claude &> /dev/null; then
    AGENT_CMD="claude"
elif command -v opencode &> /dev/null; then
    AGENT_CMD="opencode"
else
    echo "❌ No AI CLI found (pi, claude, opencode)."
    echo "   Install one of them: npm i -g @earendil-works/pi-coding-agent"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Agent Lint — {{PROJECT_NAME}} (via $AGENT_CMD)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FAILED=0

run_prompt() {
    local label="$1"
    local prompt_file="$2"

    if [[ ! -f "$prompt_file" ]]; then
        echo "⚠️  $label — prompt file not found: $prompt_file"
        FAILED=1
        return
    fi

    echo "📋 $label"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Don't let a non-zero exit from one phase abort the whole lint.
    local exit_code=0
    $AGENT_CMD -p "$(cat "$prompt_file")" || exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "⚠️  $label failed (exit $exit_code)"
        FAILED=1
    fi
    echo ""
}

run_prompt "Phase 1/3: Magic Strings & Numbers Audit" "$SCRIPT_DIR/check-constants.prompt"
run_prompt "Phase 2/3: Simplify Changed Files"        "$SCRIPT_DIR/check-simplify.prompt"
run_prompt "Phase 3/3: STATUS.md Update Check"        "$SCRIPT_DIR/check-status.prompt"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $FAILED -eq 0 ]]; then
    echo "✅ Agent Lint — Done"
else
    echo "⚠️  Agent Lint — Done with warnings (some phases failed)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
