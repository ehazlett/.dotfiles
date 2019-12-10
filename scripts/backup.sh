#!/bin/bash
VOLS="tank/chroot/underland tank/chroot/work tank/containerd tank/home tank/iso tank/packages tank/root/terra"
DEST=${DEST:-/mnt/backup}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

VOLS=$VOLS DEST=$DEST $SCRIPT_DIR/zfs-backup.sh

