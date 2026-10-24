#!/usr/bin/env zsh

# --- Setup ---

brew update
brew upgrade

# --- Brew ---

brew install moreutils
brew install findutils
brew install wget
brew install vim
brew install grep
brew install openssh
brew install make
brew install ssh-copy-id
brew install openssl
brew install readline
brew install stats
brew install tree
brew install postgresql
brew install sqlite3
brew install starship
brew install git
brew install git-lfs
brew install uv
brew install television
brew install tmux
brew install git-delta
brew install ollama
brew install opencode
brew install pi-coding-agent
brew install bun
brew install gh

# --- Cask ---

brew install --cask 1password
brew install --cask docker
brew install --cask google-chrome
brew install --cask itsycal
brew install --cask karabiner-elements
brew install --cask logi-options-plus
brew install --cask postman
brew install --cask rectangle
brew install --cask spotify
brew install --cask todoist
brew install --cask zotero
brew install --cask visual-studio-code
brew install --cask wezterm
brew install --cask simplenote
brew install --cask alt-tab
brew install --cask iterm2
brew install --cask claude-code
brew install --cask claude
brew install --cask codex

# --- Setup ---

brew cleanup
