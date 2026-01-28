#!/bin/bash

# Define base directory based on your screenshot
BASE_DIR="$HOME/.config/waybar"
CONFIGS_DIR="$BASE_DIR/configs"

CONF_CHOICE=$(ls "$CONFIGS_DIR" | fuzzel --dmenu -p "Select Waybar Config: ")

if [[ -z "$CONF_CHOICE" ]]; then
    exit 0
fi

ln -sf "$CONFIGS_DIR/$CONF_CHOICE" "$BASE_DIR/config.jsonc"

pkill -USR2 waybar & notify-send "Waybar Updated" "Active config: $CONF_CHOICE"