#!/bin/bash

# $1 is the argument (play-pause, next, prev)
case $1 in
    play-pause)
        playerctl play-pause
        ;;
    next)
        playerctl next
        sleep 0.5
        ;;
    prev)
        playerctl previous
        sleep 0.5
        ;;
esac

# Get Metadata
STATUS=$(playerctl status)
ARTIST=$(playerctl metadata artist)
TITLE=$(playerctl metadata title)
ART_URL=$(playerctl metadata mpris:artUrl)

# logic to determine the "Header" (Playing/Paused)
if [ "$STATUS" == "Playing" ]; then
    HEADER="Paused" # Note: User logic seems inverted in original script, keeping as is
    FALLBACK_ICON="media-playback-start"
else
    HEADER="Playing"
    FALLBACK_ICON="󰏤"
fi

# Handle Album Art (Thumbnail)
# We define a temporary file path
ICON_PATH="/tmp/spotify_cover.jpg"

# 1. Check if ART_URL is a remote URL (http/https)
if [[ "$ART_URL" == http* ]]; then
    # Download quietly (-s) and overwrite (-o)
    curl -s "$ART_URL" -o "$ICON_PATH"
# 2. Check if ART_URL is a local file (file://)
elif [[ "$ART_URL" == file* ]]; then
    # Remove 'file://' prefix to get the actual path
    ICON_PATH="${ART_URL#file://}"
else
    # 3. No art found, use the fallback status icon
    ICON_PATH="$FALLBACK_ICON"
fi

# Send notification
# -i now points to the downloaded cover art or the fallback icon
# -r 1234 (optional): Consider adding a replace-id so notifications stack/replace each other
notify-send -a "spotify" -i "$ICON_PATH" "$HEADER" "$ARTIST - $TITLE"