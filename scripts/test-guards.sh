#!/usr/bin/env bash
# test-guards.sh: check the Claude guard hooks block and allow what they should.
# Run after editing home/.claude/hooks/. Exits non-zero on any mismatch.
set -uo pipefail

HOOKS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/home/.claude/hooks"
failed=0

# expect <block|allow> <hook> <json>
expect() {
  local want="$1" hook="$2" json="$3" got
  printf '%s' "${json}" | bash "${HOOKS}/${hook}" >/dev/null 2>&1
  [[ $? -eq 2 ]] && got=block || got=allow
  if [[ "${got}" != "${want}" ]]; then
    printf 'FAIL %-5s (got %s) %s: %s\n' "${want}" "${got}" "${hook}" "${json}"
    failed=1
  fi
}

bash_cmd() { expect "$1" bash-guard.sh "$(jq -n --arg c "$2" '{tool_input: {command: $c}}')"; }
file_op()  { expect "$1" file-guard.sh "$(jq -n --arg t "$2" --arg p "$3" '{tool_name: $t, tool_input: {file_path: $p}}')"; }

# rm: root, home and system folders themselves
bash_cmd block 'rm -rf ~'
bash_cmd block 'rm -rf ~/'
bash_cmd block 'rm -rf ~/*'
bash_cmd block 'rm -rf /'
bash_cmd block 'rm -rf "$HOME"'
bash_cmd block 'rm -rf /Users/someone'
bash_cmd block 'rm -rf /usr'
bash_cmd block 'cd /tmp && rm -rf ~'
bash_cmd allow 'rm -r ~/.agents/skills/old'
bash_cmd allow 'rm -rf /tmp/build'
bash_cmd allow 'rm -rf node_modules'
bash_cmd allow 'rm -rf /Users/someone/code/app/dist'

# Credential files: reading or copying them
bash_cmd block 'cat ~/.ssh/id_ed25519'
bash_cmd block 'head ~/.aws/credentials'
bash_cmd block 'grep KEY .env'
bash_cmd block 'cp .env /tmp/leak'
bash_cmd block 'source .env.local'
bash_cmd block 'echo hi && cat .env'
bash_cmd allow 'cat .env.example'
bash_cmd allow 'sed -n 1p ~/.config/secrets/.env.op'
bash_cmd allow 'mv a b && ls .env.op'
bash_cmd allow 'git add README.md home/.config/secrets/.env.op'
bash_cmd allow 'mv ~/op ~/.config/secrets'
bash_cmd allow 'ls ~/.config/secrets'

# The resolved secrets, named anywhere in a command
bash_cmd block 'cat ~/.config/secrets/.env'
bash_cmd block 'wc -l ~/.config/secrets/.env'

# File tools
file_op block Read  "${HOME}/.config/secrets/.env"
file_op allow Read  "${HOME}/.config/secrets/.env.op"
file_op allow Read  "${HOME}/.zshrc"
file_op block Write "${HOME}/.config/secrets/.env"
file_op block Write "${HOME}/.ssh/config"

if (( failed )); then
  echo "Guard tests failed"
  exit 1
fi
echo "Guard tests passed"
