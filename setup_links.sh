#!/bin/bash
CONFIGS="bash_profile bashrc gitconfig gitignore_global vimrc tmux.conf inputrc"

for CFG in $CONFIGS; do
    ln -sf $(pwd)/$CFG ~/.$CFG
done

# sway
mkdir -p ~/.config/sway
ln -sf $(pwd)/swayconfig ~/.config/sway/config

# term
mkdir -p ~/.config/alacritty
ln -sf $(pwd)/alacritty.yml ~/.config/alacritty/alacritty.yml

ln -sf $(pwd)/ssh_config ~/.ssh/config

# vim
rm -rf ~/.vim
ln -sf $(pwd)/vim ~/.vim
