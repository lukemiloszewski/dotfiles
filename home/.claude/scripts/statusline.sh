#!/bin/bash
# Claude Code Statusline
#
#   [directory][branch]
#   Model | +added/-removed | $cost
#   ctx 30% (301k/1M) | 5h 86% (resets 14:30) | 7d 14% (resets Sat 10:00)
#
# Add to .claude/settings.json:
# {
#   "statusLine": {
#     "type": "command",
#     "command": "bash ~/.claude/scripts/statusline.sh --detail full --color-usage all --cost"
#   }
# }
#
# Options:
#   --detail minimal|full        full adds token counts and reset times (default: minimal)
#   --color-usage none|context|limits|all
#                                colour percentages green/yellow/red by level (default: none)
#   --cost / --no-cost           show the session cost (default: --cost)

DETAIL="minimal"
COLOR_USAGE="none"
SHOW_COST=1
while [ $# -gt 0 ]; do
    case "$1" in
        --detail) DETAIL="$2"; shift 2 ;;
        --color-usage) COLOR_USAGE="$2"; shift 2 ;;
        --cost) SHOW_COST=1; shift ;;
        --no-cost) SHOW_COST=0; shift ;;
        *) shift ;;
    esac
done

input=$(cat)

# Colors
BLUE='\033[1;34m'
GREEN='\033[1;32m'
GRAY='\033[90m'
MUTED_GREEN='\033[38;5;65m'
MUTED_YELLOW='\033[38;5;179m'
MUTED_RED='\033[38;5;131m'
RESET='\033[0m'

field() { echo "$input" | jq -r "$1 // empty"; }

# Extract values
MODEL=$(field '.model.display_name')
CURRENT_DIR=$(field '.workspace.current_dir')
PROJECT_DIR=$(field '.workspace.project_dir')
LINES_ADDED=$(field '.cost.total_lines_added'); LINES_ADDED=${LINES_ADDED:-0}
LINES_REMOVED=$(field '.cost.total_lines_removed'); LINES_REMOVED=${LINES_REMOVED:-0}
COST=$(printf "%.2f" "$(field '.cost.total_cost_usd')" 2>/dev/null || echo "0.00")

CTX_PCT=$(field '.context_window.used_percentage')
CTX_SIZE=$(field '.context_window.context_window_size')
CTX_USAGE=$(echo "$input" | jq -r '.context_window.current_usage // empty
    | (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)')
FIVE_PCT=$(field '.rate_limits.five_hour.used_percentage')
FIVE_RESET=$(field '.rate_limits.five_hour.resets_at')
WEEK_PCT=$(field '.rate_limits.seven_day.used_percentage')
WEEK_RESET=$(field '.rate_limits.seven_day.resets_at')

# 301495 -> 301k, 1000000 -> 1M
human() {
    awk -v n="$1" 'BEGIN {
        if (n >= 1000000) { v = n / 1000000; printf (v == int(v) ? "%dM" : "%.1fM"), v }
        else if (n >= 1000) printf "%dk", n / 1000
        else printf "%d", n
    }'
}

# Epoch seconds -> 14:30 (within a day) or Sat 10:00 (later), on macOS or Linux
reset_time() {
    local fmt="%H:%M"
    [ $(( $1 - $(date +%s) )) -gt 86400 ] && fmt="%a %H:%M"
    date -r "$1" +"$fmt" 2>/dev/null || date -d "@$1" +"$fmt" 2>/dev/null
}

# Colour a percentage when --color-usage covers this kind of usage
colored_pct() {
    local pct="$1" kind="$2" color="$GRAY"
    if [ "$COLOR_USAGE" = "all" ] || [ "$COLOR_USAGE" = "$kind" ]; then
        if [ "$pct" -ge 80 ]; then color="$MUTED_RED"
        elif [ "$pct" -ge 50 ]; then color="$MUTED_YELLOW"
        else color="$MUTED_GREEN"; fi
    fi
    printf "%b%s%%%b" "$color" "$pct" "$GRAY"
}

# Git branch
GIT_BRANCH=""
if git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT_BRANCH="[${GREEN}${BRANCH}${RESET}]"
fi

# Directory display
if [ -z "$PROJECT_DIR" ] || [ "$PROJECT_DIR" = "$CURRENT_DIR" ]; then
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

# Line 3: context window and plan usage limits
USAGE=()
if [ -n "$CTX_PCT" ]; then
    SEGMENT="ctx $(colored_pct "$CTX_PCT" context)"
    if [ "$DETAIL" = "full" ] && [ -n "$CTX_USAGE" ] && [ -n "$CTX_SIZE" ]; then
        SEGMENT+=" ($(human "$CTX_USAGE")/$(human "$CTX_SIZE"))"
    fi
    USAGE+=("$SEGMENT")
fi
for limit in "5h:$FIVE_PCT:$FIVE_RESET" "7d:$WEEK_PCT:$WEEK_RESET"; do
    IFS=: read -r label pct reset <<< "$limit"
    [ -z "$pct" ] && continue
    SEGMENT="$label $(colored_pct "$pct" limits)"
    [ "$DETAIL" = "full" ] && [ -n "$reset" ] && SEGMENT+=" (resets $(reset_time "$reset"))"
    USAGE+=("$SEGMENT")
done

LINE1="[${BLUE}${DIR_DISPLAY}${RESET}]${GIT_BRANCH}"
LINE2="${GRAY}${MODEL} | ${MUTED_GREEN}+${LINES_ADDED}${GRAY}/${MUTED_RED}-${LINES_REMOVED}${GRAY}"
[ "$SHOW_COST" -eq 1 ] && LINE2+=" | \$${COST}"
LINE2+="${RESET}"

echo -e "${LINE1}\n${LINE2}"
if [ ${#USAGE[@]} -gt 0 ]; then
    LINE3=$(printf " | %s" "${USAGE[@]}")
    echo -e "${GRAY}${LINE3:3}${RESET}"
fi
