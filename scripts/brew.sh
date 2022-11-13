#!/usr/bin/env zsh

# --- Setup ---

brew update
brew upgrade

# --- Brew ---

brew install moreutils
brew install findutils
brew install gnu-sed --with-default-names
brew install wget --with-iri
brew install vim --with-override-system-vi
brew install grep
brew install openssh
brew install make
brew install ack
brew install git
brew install git-lfs
brew install ssh-copy-id
brew install tree
brew install postgresql
brew install openssl
brew install readline
brew install sqlite3
brew install xz
brew install zlib
brew install pyenv
brew install poetry
brew install pipx
brew install starship
brew install stats

# --- Cask ---

brew install --cask 1password
brew install --cask anki
brew install --cask discord
brew install --cask docker
brew install --cask google-chrome
brew install --cask iterm2
brew install --cask itsycal
brew install --cask postman
brew install --cask rectangle
brew install --cask slack
brew install --cask spotify
brew install --cask todoist
brew install --cask visual-studio-code
brew install --cask vlc
brew install --cask zoom
brew install --cask raycast

# --- Setup ---

brew cleanup
