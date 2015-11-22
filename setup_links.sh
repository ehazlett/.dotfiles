#!/bin/bash
CONFIGS="bashrc gitconfig gitignore_global vimrc tmux.conf i3status.conf"

for CFG in $CONFIGS; do
    ln -sf $(pwd)/$CFG ~/.$CFG
done

VENDOR=$(cat /sys/class/dmi/id/sys_vendor)

# i3
rm -rf ~/.i3/config
if [ "$VENDOR" = "Apple Inc." ]; then
	ln -sf $(pwd)/i3config.macbook ~/.i3/config
else
	ln -sf $(pwd)/i3config ~/.i3/config
fi

ln -sf $(pwd)/ssh_config ~/.ssh/config

# vim
rm -rf ~/.vim
ln -sf $(pwd)/vim ~/.vim
