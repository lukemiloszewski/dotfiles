#!/usr/bin/env bash

set -e

# Builds tmux 3.x into ~/.local for distributions that only package an older
# one. Set CA_BUNDLE to a certificate bundle path if downloads must trust a
# custom root (for example behind a TLS-inspecting proxy).

ROOT_DIR=${HOME}

WGET="wget${CA_BUNDLE:+ --ca-certificate=${CA_BUNDLE}}"

# Clean up
rm -rf libevent-2.1.12-stable.tar.gz
rm -rf ncurses-6.5.tar.gz
rm -rf tmux-3.6.tar.gz

$WGET "https://github.com/tmux/tmux/releases/download/3.6/tmux-3.6.tar.gz"
$WGET "https://invisible-mirror.net/archives/ncurses/ncurses-6.5.tar.gz"
$WGET "https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz"
cp -r "./libevent-2.1.12-stable.tar.gz" "./ncurses-6.5.tar.gz" "./tmux-3.6.tar.gz" ${ROOT_DIR}

cd ${ROOT_DIR}

tar xvf "libevent-2.1.12-stable.tar.gz"
tar xvf "ncurses-6.5.tar.gz"
tar xvf "tmux-3.6.tar.gz"

# Install libevent
cd libevent-2.1.12-stable
./autogen.sh
./configure --prefix=${ROOT_DIR}/.local
make
make install
cd ..

# Install ncurses
cd ncurses-6.5
./configure --prefix=${ROOT_DIR}/.local
make
make install
cd ..

# Install tmux
cd tmux-3.6
./configure --prefix=${ROOT_DIR}/.local \
    CFLAGS="-I${ROOT_DIR}/.local/include -I${ROOT_DIR}/.local/include/ncurses" \
    LDFLAGS="-L${ROOT_DIR}/.local/include -L${ROOT_DIR}/.local/include/ncurses -L${ROOT_DIR}/.local/lib -Wl,-rpath,${ROOT_DIR}/.local/lib"
make
make install
cd ..

# Clean up
rm -rf libevent-2.1.12-stable*
rm -rf ncurses-6.5*
rm -rf tmux-3.6*

echo "[SUCCESS] ${ROOT_DIR}/.local/bin/tmux is now available"
