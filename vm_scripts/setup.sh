#!/bin/bash
cp -f vm_setup /usr/local/bin/vm_setup
cp -f resize_disk /usr/local/bin/resize_disk
cp -f set_hostname /usr/local/bin/set_hostname
cp -f vm_seal /usr/local/bin/vm_seal
cp -f keyboard /etc/default/keyboard
cp -f vm_setup.service /etc/systemd/system/vm_setup.service

if [ -e /etc/debian_version ]; then
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure keyboard-configuration
    systemctl enable vm_setup
fi
