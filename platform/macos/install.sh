#!/usr/bin/env zsh
# macOS setup. macOS is the client side; development happens on a remote
# Linux host, which uses bootstrap.sh and platform/linux/.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${0:A}")/../.." && pwd)"

# close System Preferences
osascript -e 'tell application "System Preferences" to quit' || true

# ask for administrator password upfront and keep it alive until done
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# command line tools
xcode-select --install || true

# homebrew and packages
command -v brew >/dev/null 2>&1 || \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
source "${REPO_DIR}/platform/macos/brew.sh"

# tooling, shell and linking
bash "${REPO_DIR}/scripts/install.sh"

# zsh-shift-select plugin
dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-shift-select"
[ -d "${dir}" ] || git clone --depth 1 https://github.com/jirutka/zsh-shift-select.git "${dir}"
