#!/usr/bin/env bash
# git-label.sh DIR — current git branch for the tmux status bar.
# Prints the branch (or @sha when detached), and nothing outside a repo.
dir="${1:-.}"
git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[[ -n "$branch" ]] || branch="@$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"
printf '%s' "$branch"
