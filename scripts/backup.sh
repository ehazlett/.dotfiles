#!/bin/bash
VOLS="tank/chroot/underland tank/chroot/work tank/containerd tank/home tank/iso tank/packages tank/root/terra"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

VOLS=$VOLS DEST=$DEST $SCRIPT_DIR/zfs-backup.sh

