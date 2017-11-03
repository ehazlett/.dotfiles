#!/bin/bash
OUTPUT=${OUTPUT:-DP-1}
xrandr --output ${OUTPUT} --auto --above eDP-1
xrandr --output ${OUTPUT} --scale 1.5x1.5 --mode 2560x1440 --pos 0x0
xrandr --output eDP-1 --scale 1x1 --pos 800x2160
