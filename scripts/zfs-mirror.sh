#!/bin/bash
VOLS=${VOLS:-}
DEST=${DEST:-}

for vol in $VOLS; do
    echo " -> $vol"
    zfs create $(dirname "${DEST}/$vol") >/dev/null 2>&1 || true
    zfs destroy $vol@backup >/dev/null 2>&1 || true
    zfs destroy -R $DEST/$vol >/dev/null 2>&1 || true
    zfs snap $vol@backup
    zfs send $vol@backup | zfs recv $DEST/$vol
    zfs destroy $vol@backup
done
