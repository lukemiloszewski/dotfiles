#!/usr/bin/env bash
# Installs user-level tooling (no root needed), then links dotfiles.
# System packages come first: platform/linux/{dnf,apt}.sh or platform/macos/.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVM_VERSION="0.40.4"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

mkdir -p "${HOME}/code" "${HOME}/.local/bin"

# starship prompt
command -v starship >/dev/null 2>&1 || \
  curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "${HOME}/.local/bin"

# uv
command -v uv >/dev/null 2>&1 || \
  curl -LsSf https://astral.sh/uv/install.sh | sh

# rustup
command -v rustup >/dev/null 2>&1 || \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# nvm
[ -d "${HOME}/.nvm/.git" ] || [ -s "${HOME}/.nvm/nvm.sh" ] || \
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash

# git-delta (home/.gitconfig uses it as pager and diff filter, so git is
# unusable on a fresh box without it)
if ! command -v delta >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install git-delta
  else
    # shellcheck source=/dev/null
    [ -f "${HOME}/.cargo/env" ] && . "${HOME}/.cargo/env"
    cargo install git-delta
  fi
fi

# oh-my-zsh, keeping the linked ~/.zshrc
[ -d "${HOME}/.oh-my-zsh" ] || \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

for plugin in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
  dir="${ZSH_CUSTOM}/plugins/${plugin#*/}"
  [ -d "${dir}" ] || git clone --depth 1 "https://github.com/${plugin}.git" "${dir}"
done

# zsh as default shell
[ "${SHELL:-}" = "$(command -v zsh)" ] || chsh -s "$(command -v zsh)"

bash "${REPO_DIR}/bootstrap.sh"
