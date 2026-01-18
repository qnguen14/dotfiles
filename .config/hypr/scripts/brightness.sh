#!/bin/bash

# $1 is the argument (up, down)
case $1 in
    up)
        brightnessctl s 5%+
        ;;
    down)
        brightnessctl s 5%-
        ;;
esac

# Get current brightness percentage
CURRENT=$(brightnessctl i | grep -oP '\(\K[^%]+')

notify-send -a "brightnessctl" -h int:value:"$CURRENT" "Brightness" "${CURRENT}%"