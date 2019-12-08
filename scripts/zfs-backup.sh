#!/bin/bash
VOLS=${VOLS:-}
DEST=${DEST:-}
SNAP=${SNAP:-"$(date +%Y%m%d-%H%M)"}

if [ -z "$VOLS" ]; then
    echo "VOLS env var must be specified"
    exit 1
fi

if [ -z "$DEST" ]; then
    echo "DEST env var must be specified"
    exit 1
fi

echo " -> starting backup for $SNAP"
mkdir -p $DEST/$SNAP

zfs list $VOLS > $DEST/$SNAP/zfs-vols

for vol in $VOLS; do
    echo " -> $vol"
    zfs snap $vol@$SNAP
    target=$(echo $vol | tr '/', '_')
    zfs send $vol@$SNAP > $DEST/$SNAP/$target
    zfs destroy $vol@$SNAP
done
