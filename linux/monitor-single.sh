#!/bin/bash
OUTPUT=${OUTPUT:-DP-1}
xrandr --output ${OUTPUT} --auto
#xrandr --output ${OUTPUT} --scale 1.5x1.5 --mode 2560x1440 --pos 0x0
xrandr --output eDP-1 --off
