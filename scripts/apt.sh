packages="zsh \
    openssh-clients \
    wget \
    curl \
    rsync \
    vim-minimal \
    moreutils \
    findutils \
    sed \
    grep \
    make \
    ack \
    git \
    git-lfs \
    tree \
    sqlite \
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

dnf install -y ${packages} \
    && dnf autoremove -y \
    && dnf clean all
