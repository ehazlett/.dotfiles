#!/bin/bash
USER_NAME=${1:-ehazlett}

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    gcc \
    git-core \
    make \
    python \
    python-dev \
    python-setuptools \
    autoconf \
    gawk \
    libncurses5-dev \
    libssl-dev \
    mercurial \
    aufs-tools \
    libbz2-dev \
    libreadline-dev \
    lxc \
    gettext \
    htop \
    wget \
    sysstat \
    curl \
    socat \
    tmux \
    ctags \
    libsqlite3-dev \
    libdevmapper-dev \

export USER_NAME=$USER_NAME

cd /home/$USER_NAME

git clone https://github.com/ehazlett/.dotfiles
cd .dotfiles
git submodule update --init

/bin/bash config.sh
