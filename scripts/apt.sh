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
    less \
    tar \
    tmux \
    gcc \
    gcc-c++ \
    bzip2 \
    bzip2-devel \
    libffi-devel \
    openssl-devel \
    readline-devel \
    unixODBC-devel \
    xz \
    zlib-devel \
    '@Development Tools'"

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq \
    && apt-get -y install --no-install-recommends ${packages} \
    && apt-get autoremove -y \
    && apt-get clean -y \

export DEBIAN_FRONTEND=dialog
