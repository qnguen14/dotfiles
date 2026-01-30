#!/bin/bash

# Define base directory based on your screenshot
BASE_DIR="$HOME/.config/waybar"
STYLES_DIR="$BASE_DIR/styles"

CONF_CHOICE=$(ls "$STYLES_DIR" | fuzzel --dmenu -p "Select Waybar Style: ")

if [[ -z "$CONF_CHOICE" ]]; then
    exit 0
fi

ln -sf "$STYLES_DIR/$CONF_CHOICE" "$BASE_DIR/style.css"

$HOME/.config/waybar/scripts/launch.sh & notify-send "Waybar Updated" "Active style: $CONF_CHOICE"