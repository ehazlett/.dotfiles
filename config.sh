#!/bin/bash
set -e
USER_NAME=${1:-ehazlett}
export HOME=/home/$USER_NAME
cd /home/$USER_NAME
if [ -e "/usr/local/bin/fish" ]
then
    echo "Fish already installed..."
else
    wget http://fishshell.com/files/2.1.1/fish-2.1.1.tar.gz
    tar -zxf fish-2.1.1.tar.gz && cd fish-2.1.1
    ./configure --prefix=/usr/local
    make && make install
    echo '/usr/local/bin/fish' | tee -a /etc/shells
    chsh -s /usr/local/bin/fish $USER_NAME
    rm -rf /home/$USER_NAME/fish-*
fi 

cd /home/$USER_NAME

if [ -d "/usr/local/bin/vim" ]
then
    echo "Vim already installed..."
else
    hg clone https://vim.googlecode.com/hg/ vim
    cd vim/src
    ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge
    make
    make install
    rm -rf /home/$USER_NAME/vim
fi

cd /home/$USER_NAME

if [ -d "/usr/local/go/bin/go" ]
then
    echo "Go already installed..."
else 
    wget https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz -O /tmp/go.tar.gz
    tar -C /usr/local -xvf /tmp/go.tar.gz
fi
cd /home/$USER_NAME

if [ -f "/home/$USER_NAME/.config/fish/config.fish" ]
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
    # install nvm
    cd $HOME && git clone https://github.com/Alex7Kom/nvm-fish.git .nvm
    echo "test -s /home/dev/.nvm-fish/nvm.fish; and source /home/dev/.nvm-fish/nvm.fish" >> $HOME/.config/fish/config.fish
fi
cd /home/$USER_NAME

# ip forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
groupadd docker
usermod -G docker -a $USER_NAME

