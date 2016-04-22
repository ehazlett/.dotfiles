#!/bin/bash
xrandr --output DP1 --auto --above eDP1
xrandr --output DP1 --scale 1.5x1.5 --mode 2560x1440 --pos 0x0
xrandr --output eDP1 --scale 1x1 --pos 800x2160
