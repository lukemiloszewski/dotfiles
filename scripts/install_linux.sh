#!/bin/bash

# install starship prompt
curl -sS https://starship.rs/install.sh | sh -s -- -y

# install pyenv
curl https://pyenv.run | bash

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# install oh-my-zsh (creating `~/.oh-my-zsh` and `~/.zshrc`)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# set zsh as default shell
chsh -s $(which zsh)

cp -r "${HOME}/dotfiles/.aliases" "${HOME}/.aliases"
cp -r "${HOME}/dotfiles/.ansible.cfg" "${HOME}/.ansible.cfg"
cp -r "${HOME}/dotfiles/.config" "${HOME}/.config"
cp -r "${HOME}/dotfiles/.exports" "${HOME}/.exports"
cp -r "${HOME}/dotfiles/.ipython" "${HOME}/.ipython"
cp -r "${HOME}/dotfiles/.functions" "${HOME}/.functions"
cp -r "${HOME}/dotfiles/.gitconfig" "${HOME}/.gitconfig"
cp -r "${HOME}/dotfiles/.pyflyby" "${HOME}/.pyflyby"
cp -r "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"
