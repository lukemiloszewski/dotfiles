#!/bin/bash

mkdir -p "${HOME}/code"

# install starship prompt
curl -sS https://starship.rs/install.sh | sh -s -- -y

# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# install rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# install oh-my-zsh (creating `~/.oh-my-zsh` and `~/.zshrc`)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# set zsh as default shell
chsh -s $(which zsh)

cp -r "${HOME}/code/dotfiles/.aliases" "${HOME}/.aliases"
cp -r "${HOME}/code/dotfiles/.ansible.cfg" "${HOME}/.ansible.cfg"
cp -r "${HOME}/code/dotfiles/.config" "${HOME}/.config"
cp -r "${HOME}/code/dotfiles/.exports" "${HOME}/.exports"
cp -r "${HOME}/code/dotfiles/.gitconfig" "${HOME}/.gitconfig"
cp -r "${HOME}/code/dotfiles/.zshrc" "${HOME}/.zshrc"
