#!/bin/bash

mkdir -p "${HOME}/code"

# install starship prompt (user-local, no sudo required)
curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir ~/.local/bin

# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# install rustup
mkdir -p "${HOME}/tmp"
TMPDIR="${HOME}/tmp" curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
rm -rf "${HOME}/tmp"

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

ln -sf "${HOME}/code/dotfiles/.aliases"     "${HOME}/.aliases"
ln -sf "${HOME}/code/dotfiles/.ansible.cfg" "${HOME}/.ansible.cfg"
ln -sf "${HOME}/code/dotfiles/.config"      "${HOME}/.config"
ln -sf "${HOME}/code/dotfiles/.exports"     "${HOME}/.exports"
ln -sf "${HOME}/code/dotfiles/.gitconfig"   "${HOME}/.gitconfig"
ln -sf "${HOME}/code/dotfiles/.zshrc_linux" "${HOME}/.zshrc"
