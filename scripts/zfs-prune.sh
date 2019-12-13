#!/bin/bash
set +e
KEEP=${KEEP:-5}
VOLS=${VOLS:-"$(zfs list -H | awk '{ print $1; }')"}

for vol in $VOLS; do
    snaps=($(zfs list -H -t snap $vol | awk '{ print $1; }'))
    if [ $? -eq 0 ]; then
        num=${#snaps[@]}
        # always keep the first
        for (( i=1; i<=$(( $num - $KEEP-1 )); i++ )); do
            echo " -> removing ${snaps[$i]}"
            zfs destroy ${snaps[$i]}
        done
    fi
done
