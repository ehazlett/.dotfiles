#!/bin/sh
VOLS="tank/home tank/root tank/chroot"

d=$(date +%Y%m%d-%H%M)
echo $d

for v in $VOLS; do
    zfs snap $v@$d
done
