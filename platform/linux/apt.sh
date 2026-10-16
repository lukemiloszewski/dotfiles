#!/usr/bin/env bash
# System packages for Debian-family distributions (run as root).
set -euo pipefail

packages="zsh \
    openssh-client \
    wget \
    curl \
    rsync \
    vim \
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
    jq \
    xclip \
    build-essential \
    libffi-dev \
    libssl-dev \
    libreadline-dev \
    unixodbc-dev \
    xz-utils \
    zlib1g-dev"

apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${packages} \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
