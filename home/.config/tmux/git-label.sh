#!/usr/bin/env bash
# git-label.sh DIR — short git label for the tmux status bar.
# Prints "branch" in a normal checkout, "worktree:branch" in a linked
# worktree, and nothing outside a repo.
dir="${1:-.}"
git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[[ -n "$branch" ]] || branch="@$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"

git_dir=$(git -C "$dir" rev-parse --absolute-git-dir 2>/dev/null)
common_dir=$(cd "$dir" && cd "$(git rev-parse --git-common-dir 2>/dev/null)" && pwd)
if [[ "$git_dir" != "$common_dir" ]]; then
  worktree=$(basename "$(git -C "$dir" rev-parse --show-toplevel)")
  printf '%s:%s' "$worktree" "$branch"
else
  printf '%s' "$branch"
fi
