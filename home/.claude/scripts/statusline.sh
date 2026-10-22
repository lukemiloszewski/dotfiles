#!/bin/bash
# Claude Code Statusline - simplified, zero-config
#
# Add to .claude/settings.json:
# {
#   "statusLine": {
#     "type": "command",
#     "command": "bash .claude/scripts/statusline.sh"
#   }
# }

input=$(cat)

# Colors
BLUE='\033[1;34m'
GREEN='\033[1;32m'
GRAY='\033[90m'
MUTED_GREEN='\033[38;5;65m'
MUTED_RED='\033[38;5;131m'
RESET='\033[0m'

# Extract values
MODEL=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed')
COST=$(printf "%.2f" "$(echo "$input" | jq -r '.cost.total_cost_usd // 0')" 2>/dev/null || echo "0.00")

COST=$(printf "%.2f" "$(echo "$input" | jq -r '.cost.total_cost_usd')")
COST_SEGMENT="\$${COST}"

# Git branch
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT_BRANCH="[${GREEN}${BRANCH}${RESET}]"
fi

# Directory display
if [ -z "$PROJECT_DIR" ] || [ "$PROJECT_DIR" = "null" ] || [ "$PROJECT_DIR" = "$CURRENT_DIR" ]; then
    PROJECT_DIR=$(git -C "$CURRENT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$CURRENT_DIR")
fi
PROJECT_NAME="${PROJECT_DIR##*/}"
CURRENT_NAME="${CURRENT_DIR##*/}"
if [ "$CURRENT_DIR" = "$PROJECT_DIR" ]; then
    DIR_DISPLAY="$CURRENT_NAME"
elif [ "${CURRENT_DIR#$PROJECT_DIR/}" != "$CURRENT_DIR" ]; then
    REL_PATH="${CURRENT_DIR#$PROJECT_DIR/}"
    DEPTH=$(echo "$REL_PATH" | tr -cd '/' | wc -c)
    if [ "$DEPTH" -eq 0 ]; then
        DIR_DISPLAY="./${PROJECT_NAME}/${CURRENT_NAME}"
    else
        DIR_DISPLAY="./${PROJECT_NAME}/../${CURRENT_NAME}"
    fi
else
    DIR_DISPLAY="$CURRENT_NAME"
fi

# Two-line output
LINE1="[${BLUE}${DIR_DISPLAY}${RESET}]${GIT_BRANCH}"
LINE2="${GRAY}${MODEL} | ${MUTED_GREEN}+${LINES_ADDED}${GRAY}/${MUTED_RED}-${LINES_REMOVED}${GRAY} | ${COST_SEGMENT}${RESET}"

echo -e "${LINE1}\n${LINE2}"
