packages="zsh \
    apt-utils \
    openssh-client \
    wget \
    curl \
    rsync \
    vim-tiny \
    moreutils \
    findutils \
    sed \
    grep \
    make \
    ack \
    git \
    git-lfs \
    tree \
    sqlite3 \
    lsof \
    htop \
    net-tools \
    ca-certificates \
    zip \
    unzip \
    less"

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq \
    && apt-get -y install --no-install-recommends ${packages} \
    && apt-get autoremove -y \
    && apt-get clean -y \

export DEBIAN_FRONTEND=dialog

curl -sS https://starship.rs/install.sh | sh -s -- -y

# install oh-my-zsh (creating `~/.oh-my-zsh` and `~/.zshrc`)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Installing defaults"

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Setting zsh as default shell"

# set zsh as default shell
chsh -s $(which zsh)

echo "Linking dotfiles"

ln -sf "/workspaces/dotfiles/.aliases" "${HOME}/.aliases"
ln -sf "/workspaces/dotfiles/.ansible.cfg" "${HOME}/.ansible.cfg"
ln -sf "/workspaces/dotfiles/.config" "${HOME}/.config"
ln -sf "/workspaces/dotfiles/.exports" "${HOME}/.exports"
ln -sf "/workspaces/dotfiles/.ipython" "${HOME}/.ipython"
ln -sf "/workspaces/dotfiles/.functions" "${HOME}/.functions"
ln -sf "/workspaces/dotfiles/.gitconfig" "${HOME}/.gitconfig"
ln -sf "/workspaces/dotfiles/.macos" "${HOME}/.macos"
ln -sf "/workspaces/dotfiles/.nvm" "${HOME}/.nvm"
ln -sf "/workspaces/dotfiles/.pyflyby" "${HOME}/.pyflyby"
ln -sf "/workspaces/dotfiles/.zprofile" "${HOME}/.zprofile"
ln -sf "/workspaces/dotfiles/.zshrc" "${HOME}/.zshrc"

exec zsh
