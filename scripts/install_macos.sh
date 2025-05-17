#!/usr/bin/env zsh

# close System Preferences
osascript -e 'tell application "System Preferences" to quit'

# ask for administrator password upfront
sudo -v

# update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install command line tools
xcode-select --install

# install Homebrew
/bin/bash -c "$(curl -fsSL <https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh>)"

# install system packages with Homebrew
source ~/dotfiles/scripts/brew.sh

# configure SSH key with GitHub
source ~/dotfiles/scripts/ssh.sh

# configure macOS defaults
# source ~/dotfiles/.macos

# install oh-my-zsh (creating `~/.oh-my-zsh` and `~/.zshrc`)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install nvm
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# create code directory
mkdir -p "${HOME}/code"

# set zsh as default shell
chsh -s $(which zsh)

# clone and link dotfiles
ln -sf "${HOME}/code/dotfiles/.aliases" "${HOME}/.aliases"
ln -sf "${HOME}/code/dotfiles/.ansible.cfg" "${HOME}/.ansible.cfg"
ln -sf "${HOME}/code/dotfiles/.config" "${HOME}/.config"
ln -sf "${HOME}/code/dotfiles/.exports" "${HOME}/.exports"
ln -sf "${HOME}/code/dotfiles/.functions" "${HOME}/.functions"
ln -sf "${HOME}/code/dotfiles/.gitconfig" "${HOME}/.gitconfig"
ln -sf "${HOME}/code/dotfiles/.macos" "${HOME}/.macos"
ln -sf "${HOME}/code/dotfiles/.nvm" "${HOME}/.nvm"
ln -sf "${HOME}/code/dotfiles/.zprofile" "${HOME}/.zprofile"
ln -sf "${HOME}/code/dotfiles/.zshrc" "${HOME}/.zshrc"
