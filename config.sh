#!/bin/bash
set -e

# VIM
if [ -d "/usr/local/bin/vim" ] && [ -z "$SKIP_VIM" ]; then
    echo "Vim already installed..."
else
    cd /tmp
    git clone https://github.com/vim/vim
    cd vim/src
    ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge
    make
    make install
fi

# Go
if [ -d "/usr/local/go/bin/go" ] && [ -z "$SKIP_GO" ]; then
    echo "Go already installed..."
else
    curl -sSL https://storage.googleapis.com/golang/go1.11.4.linux-amd64.tar.gz -o /tmp/go.tar.gz
    tar -C /usr/local -xvf /tmp/go.tar.gz
fi

# Protobuf
if [ -d "/usr/local/bin/protoc" ]; && [ -z "$SKIP_PROTOBUF" ]; then
    echo "Protobuf support already installed..."
else
    curl -sSL https://github.com/google/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip -o /tmp/protoc.tar.gz
    tar -C /usr/local -xvf /tmp/go.tar.gz
fi

# User setup
if [ -z "SKIP_USER" ]; then
    USER_NAME=${1:-hatter}
    export HOME=/home/$USER_NAME

    su - $USER

    mkdir -p .ssh
    cd $HOME/.dotfiles

    rm -rf /home/$USER_NAME/.vim
    ./setup_links.sh

    # temporarily remove custom scheme to prevent vim launch errors before vundle run
    sed -i 's/^colorscheme.*//g' $HOME/.dotfiles/vimrc
    # vim plugins
    vim +PluginInstall +qall
    # restore vimrc
    cd $HOME/.dotfiles && git checkout vimrc
    reset

    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
    groupadd docker
    usermod -aG docker $USER_NAME
    usermod -aG sudo $USER_NAME
    usermod -s /bin/bash $USER_NAME
    echo "Changing password for $USER_NAME"
    passwd $USER_NAME
fi

# ip forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

