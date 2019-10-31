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

ln -sf $(pwd)/gtk.css ~/.config/gtk-3.0/gtk.css

