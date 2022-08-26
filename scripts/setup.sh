#!/usr/bin/env zsh

# close System Preferences
osascript -e 'tell application "System Preferences" to quit'

# ask for administrator password upfront
sudo -v

# update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install command line tools
xcode-select --install

# clone and link dotfiles
git clone https://github.com/lukemiloszewski/dotfiles.git "${HOME}/dotfiles"
ln -s "${HOME}/dotfiles/.aliases" "${HOME}/.aliases"
ln -s "${HOME}/dotfiles/.ansible.cfg" "${HOME}/.ansible.cfg"
ln -s "${HOME}/dotfiles/.config" "${HOME}/.config"
ln -s "${HOME}/dotfiles/.exports" "${HOME}/.exports"
ln -s "${HOME}/dotfiles/.ipython" "${HOME}/.ipython"
ln -s "${HOME}/dotfiles/.functions" "${HOME}/.functions"
ln -s "${HOME}/dotfiles/.gitconfig" "${HOME}/.gitconfig"
ln -s "${HOME}/dotfiles/.macos" "${HOME}/.macos"
ln -s "${HOME}/dotfiles/.nvm" "${HOME}/.nvm"
ln -s "${HOME}/dotfiles/.zprofile" "${HOME}/.zprofile"
ln -s "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"

# install Homebrew
/bin/bash -c "$(curl -fsSL <https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh>)"

# install packages with Homebrew
source ~/dotfiles/scripts/brew.sh

# setup SSH key with GitHub
source ~/dotfiles/scripts/ssh.sh

# configure macOS defaults
source ~/dotfiles/.macos

# install oh-my-zsh (creating `~/.oh-my-zsh` and `~/.zshrc`)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# create code directory
mkdir -p "${HOME}/code"
