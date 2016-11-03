#!/bin/bash
DEST=${1:-}

if [ -z "$DEST" ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

scp ~/.ssh/id_rsa.pub $DEST:~/.ssh/authorized_keys

scp vm_setup $DEST:/usr/local/bin/vm_setup
scp resize_disk $DEST:/usr/local/bin/resize_disk
scp set_hostname $DEST:/usr/local/bin/set_hostname
scp vm_seal $DEST:/usr/local/bin/vm_seal
scp keyboard $DEST:/etc/default/keyboard
scp vm_setup.service $DEST:/etc/systemd/system/vm_setup.service

if [ -e /etc/debian_version ]; then
    ssh $DEST -- DEBIAN_FRONTEND=noninteractive dpkg-reconfigure keyboard-configuration
    ssh $DEST -- systemctl enable vm_setup
fi
