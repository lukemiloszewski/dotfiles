#!/usr/bin/env zsh

# --- Setup ---

brew update
brew upgrade

# --- Brew ---

brew install moreutils
brew install findutils
brew install gnu-sed
brew install wget
brew install vim
brew install grep
brew install openssh
brew install make
brew install ack
brew install ssh-copy-id
brew install openssl
brew install readline
brew install xz
brew install zlib
brew install stats
brew install tree
brew install postgresql
brew install sqlite3
brew install starship
brew install git
brew install git-lfs
brew install uv
brew install television
brew install ollama

# --- Cask ---

brew install --cask 1password
brew install --cask docker
brew install --cask google-chrome
brew install --cask itsycal
brew install --cask ghossty
brew install --cask logi-options-plus
brew install --cask postman
brew install --cask rectangle
brew install --cask spotify
brew install --cask todoist
brew install --cask zotero
brew install --cask visual-studio-code
brew install --cask simplenote
brew install --cask alt-tab

# --- Setup ---

brew cleanup
