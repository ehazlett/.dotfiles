#!/bin/bash
CONFIGS="bashrc gitconfig gitignore_global vimrc tmux.conf i3status.conf inputrc"

for CFG in $CONFIGS; do
    ln -sf $(pwd)/$CFG ~/.$CFG
done

if [ -e /sys/class/dmi/id/sys_vendor ]; then
    VENDOR=$(cat /sys/class/dmi/id/sys_vendor)
fi

# i3
rm -rf ~/.i3/config
if [ "$VENDOR" = "Apple Inc." ]; then
	ln -sf $(pwd)/i3config.macbook ~/.i3/config
else
	ln -sf $(pwd)/i3config ~/.i3/config
fi

rm -rf ~/.i3status.conf
if [ "$VENDOR" = "Dell Inc." ]; then
	ln -sf $(pwd)/i3status.conf.xps ~/.i3status.conf
elif [ "$VENDOR" = "LENOVO" ]; then
	ln -sf $(pwd)/i3status.conf.x1 ~/.i3status.conf
else
    echo "Unknown sys vendor: using generic i3status.conf"
    ln -sf $(pwd)/i3status.conf.vm ~/.i3status.conf
fi

ln -sf $(pwd)/gtk.css ~/.config/gtk-3.0/gtk.css

ln -sf $(pwd)/ssh_config ~/.ssh/config

# vim
rm -rf ~/.vim
ln -sf $(pwd)/vim ~/.vim
