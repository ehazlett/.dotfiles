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
    cd /home/$USER_NAME
    mkdir -p .ssh
    mkdir -p .config/fish

    rm -rf /home/$USER_NAME/.vim
    ln -sf /home/$USER_NAME/.dotfiles/vim /home/$USER_NAME/.vim
    ln -sf /home/$USER_NAME/.dotfiles/vimrc /home/$USER_NAME/.vimrc
    ln -sf /home/$USER_NAME/.dotfiles/tmux.conf /home/$USER_NAME/.tmux.conf
    # my specific settings
    if [ $USER_NAME == "ehazlett" ]; then
        ln -sf /home/$USER_NAME/.dotfiles/ssh_config /home/$USER_NAME/.ssh/config
        ln -sf /home/$USER_NAME/.dotfiles/gitconfig /home/$USER_NAME/.gitconfig
        ln -sf /home/$USER_NAME/.dotfiles/gitignore_global /home/$USER_NAME/.gitignore_global
        ln -sf /home/$USER_NAME/.dotfiles/config.fish /home/$USER_NAME/.config/fish/config.fish
    fi
    # temporarily remove custom scheme to prevent vim launch errors before vundle run
    sed -i 's/^colorscheme.*//g' $HOME/.dotfiles/vimrc
    # vim plugins
    vim +PluginInstall +qall
    # restore vimrc
    cd $HOME/.dotfiles && git checkout vimrc
fi

if [ ! -z "$(which protoc)" ];
then
    echo "Protobuf already installed..."
else
    git clone https://github.com/google/protobuf /tmp/protobuf
    cd /tmp/protobuf
    git checkout 3.5.x
    ./autogen.sh
    ./configure.sh
    make -j4
    make install
fi

# ip forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
