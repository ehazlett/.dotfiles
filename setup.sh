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

git clone https://github.com/ehazlett/.dotfiles
cd .dotfiles

/bin/bash config.sh
