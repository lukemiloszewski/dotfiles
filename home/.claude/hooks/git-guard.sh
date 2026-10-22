#!/bin/bash
# Git command safety guard for bypass mode
# Exit 0 = allow, Exit 2 = block with message to stderr

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for safety hooks but not found. Install with: brew install jq" >&2
    exit 2
fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

# === BLOCKED PATTERNS ===

DANGEROUS_PATTERNS=(
    "git reset --hard"
    "git clean -fd"
    "git clean -f"
    "git branch -D"
    "git checkout \."
    "git restore \."
    "push --force"
    "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
        exit 2
    fi
done

# === ALLOWED ===
exit 0
