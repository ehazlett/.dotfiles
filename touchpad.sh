#!/bin/bash
VENDOR=$(cat /sys/class/dmi/id/sys_vendor)
if [ "$VENDOR" = "Dell Inc." ]; then
    xinput set-prop 13 292 1
elif [ "$VENDOR" = "LENOVO" ]; then
    xinput set-prop 15 292 1
else
    echo "Unknown sys vendor ($VENDOR): skipping touchpad setup"
fi
