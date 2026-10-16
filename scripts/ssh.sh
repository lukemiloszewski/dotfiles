#!/usr/bin/env bash
# Generates an ed25519 key for GitHub and prints the public half.
# Usage: ssh.sh <email>
set -euo pipefail

email="${1:?usage: ssh.sh <email>}"
key="${HOME}/.ssh/id_ed25519"

mkdir -p "${HOME}/.ssh" && chmod 700 "${HOME}/.ssh"
[ -f "${key}" ] || ssh-keygen -t ed25519 -C "${email}" -f "${key}"

if ! grep -qs "IdentityFile ${key}" "${HOME}/.ssh/config"; then
  {
    printf 'Host *\n    AddKeysToAgent yes\n    IdentityFile %s\n' "${key}"
    [ "$(uname -s)" = "Darwin" ] && printf '    UseKeychain yes\n'
  } >> "${HOME}/.ssh/config"
fi

eval "$(ssh-agent -s)" >/dev/null
if [ "$(uname -s)" = "Darwin" ]; then
  ssh-add --apple-use-keychain "${key}"
else
  ssh-add "${key}"
fi

# add this to GitHub
cat "${key}.pub"
