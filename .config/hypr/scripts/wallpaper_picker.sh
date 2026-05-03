#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper.jpg"

MODE="dark"            # options: light, dark
TYPE="scheme-content"  # options: scheme-content, scheme-tonal, scheme-fruit-salad

# Ensure directory exists and move there
mkdir -p "$WALLPAPER_DIR"
cd "$WALLPAPER_DIR" || exit 1

SELECTED_WALL=$(ls -t *.jpg *.png *.jpeg 2>/dev/null | while read -r file; do
    echo -en "$file\0icon\x1f$WALLPAPER_DIR/$file\n"
done | rofi -dmenu -p "Wallpaper >")

# Exit if no selection was made (e.g., pressed Esc)
[ -z "$SELECTED_WALL" ] && exit 1

SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === APPLY ===

matugen image "$SELECTED_PATH" -m "$MODE" -t "$TYPE" --prefer saturation

mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"