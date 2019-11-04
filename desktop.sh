#!/bin/bash

# awesome
mkdir -p ${HOME}/.config
if [ ! -e ${HOME}/.config/awesome ]; then
    ln -sf $(pwd)/awesome ${HOME}/.config/awesome
fi

# arc icons
if [ ! -e "/usr/share/icons/Arc" ]; then
    sudo cp -rf $(pwd)/arc-icons/Arc /usr/share/icons/
fi

mkdir -p ${HOME}/.config/gtk-3.0
ln -sf $(pwd)/gtk.css ${HOME}/.config/gtk-3.0/gtk.css

sudo cp -f pm-sleep.sh /etc/pm/sleep.d/lock
