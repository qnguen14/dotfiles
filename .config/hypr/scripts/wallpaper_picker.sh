#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper.jpg"
CACHE_PATH="$HOME/.cache/current_wallpaper_thumb.jpg"

cd "$WALLPAPER_DIR" || exit 1

IFS=$'\n'

SELECTED_WALL=$(for a in $(ls -t *.jpg *.png *.gif *.jpeg *.mp4 *.mkv *.webm 2>/dev/null); do 
    echo -en "$a\0icon\x1f$a\n"
done | rofi -dmenu -p "Wallpaper >")

[ -z "$SELECTED_WALL" ] && exit 1
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"
MIME_TYPE=$(file --mime-type -b "$SELECTED_PATH")

# === APPLY ===

if [[ "$MIME_TYPE" == "video/"* ]]; then
    ffmpeg -y -ss 00:00:05 -i "$SELECTED_PATH" -vframes 1 "$CACHE_PATH" > /dev/null 2>&1
    matugen image "$CACHE_PATH"
    pkill mpvpaper
    mpvpaper -o "no-audio --loop" '*' "$SELECTED_PATH" & disown
    mkdir -p "$(dirname "$SYMLINK_PATH")"
    ln -sf "$CACHE_PATH" "$SYMLINK_PATH"

else
    pkill mpvpaper
    matugen image "$SELECTED_PATH"
    mkdir -p "$(dirname "$SYMLINK_PATH")"
    ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"
fi