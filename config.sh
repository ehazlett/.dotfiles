#!/bin/bash
set -e
USER_NAME=${1:-hatter}
export HOME=/home/$USER_NAME

if [ -d "/usr/local/bin/vim" ]
then
    echo "Vim already installed..."
else
    cd /tmp
    git clone https://github.com/vim/vim
    cd vim/src
    ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge
    make
    make install
fi

if [ -d "/usr/local/go/bin/go" ]
then
    echo "Go already installed..."
else
    wget https://storage.googleapis.com/golang/go1.10.1.linux-amd64.tar.gz -O /tmp/go.tar.gz
    tar -C /usr/local -xvf /tmp/go.tar.gz
fi

if [ -f "/home/$USER_NAME/.tmux.conf" ]
then
    echo "Dotfiles already installed..."
else
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

fi

if [ ! -z "$(which protoc)" ];
then
    echo "Protobuf already installed..."
else
    git clone https://github.com/google/protobuf /tmp/protobuf
    cd /tmp/protobuf
    git checkout 3.5.x
    ./autogen.sh
    ./configure
    make -j$(cat /proc/cpuinfo  | grep processor | wc -l)
    make install
fi

# ip forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
