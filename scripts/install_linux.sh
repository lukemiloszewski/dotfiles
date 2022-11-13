#!/usr/bin/env zsh

# install system packages with apt
source "${HOME}/dotfiles/scripts/apt.sh"

# install starship prompt
curl -sS https://starship.rs/install.sh | sh -s -- -y

# install oh-my-zsh (creating `~/.oh-my-zsh` and `~/.zshrc`)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# set zsh as default shell
chsh -s $(which zsh)

ln -sf "${HOME}/dotfiles/.aliases" "${HOME}/.aliases"
ln -sf "${HOME}/dotfiles/.ansible.cfg" "${HOME}/.ansible.cfg"
ln -sf "${HOME}/dotfiles/.config" "${HOME}/.config"
ln -sf "${HOME}/dotfiles/.exports" "${HOME}/.exports"
ln -sf "${HOME}/dotfiles/.ipython" "${HOME}/.ipython"
ln -sf "${HOME}/dotfiles/.functions" "${HOME}/.functions"
ln -sf "${HOME}/dotfiles/.gitconfig" "${HOME}/.gitconfig"
ln -sf "${HOME}/dotfiles/.nvm" "${HOME}/.nvm"
ln -sf "${HOME}/dotfiles/.pyflyby" "${HOME}/.pyflyby"
ln -sf "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"

exec zsh
