#!/bin/bash
set +e
VOLS=${VOLS:-}
DEST=${DEST:-}
SNAP=${SNAP:-"$(date +%Y%m%d-%H%M)"}

if [ -z "$VOLS" ]; then
    echo "VOLS env var must be specified"
    exit 1
fi

for vol in $VOLS; do
    echo " -> $vol"
    zfs snap $vol@$SNAP
    # skip mirror if DEST is missing
    if [ -z "$DEST" ]; then
        continue
    fi
    base=$(echo $vol | cut -d'/' -f1)
    target="$DEST/$vol"
    zfs list -H $(dirname $target) > /dev/null
    if [ $? -ne 0 ]; then
        zfs create -p $(dirname $target)
    fi
    # check for existing snaps
    target_snaps=$(zfs list -H -t snap $target > /dev/null)
    if [ $? -eq 0 ]; then
        snaps="$(zfs list -H -t snap $vol)"
        # snap incremental
        oldest=$(echo $snaps | head -1 | awk '{ print $1; }' | cut -d'@' -f2)
        zfs send -RI $vol@$oldest $vol@$SNAP | zfs recv -Fu $target
    else
        # full
        zfs send -R $vol@$SNAP | zfs recv -Fu $target
    fi
done
