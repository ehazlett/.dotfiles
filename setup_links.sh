#!/bin/bash
CONFIGS="bash_profile bashrc gitconfig gitignore_global vimrc tmux.conf inputrc"

for CFG in $CONFIGS; do
    ln -sf $(pwd)/$CFG ~/.$CFG
done

# sway
mkdir -p ~/.config/sway
ln -sf $(pwd)/swayconfig ~/.config/sway/config

ln -sf $(pwd)/ssh_config ~/.ssh/config

# vim
rm -rf ~/.vim
ln -sf $(pwd)/vim ~/.vim
