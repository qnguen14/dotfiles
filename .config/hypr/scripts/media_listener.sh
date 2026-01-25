#!/bin/bash

# Kill old instances to prevent duplicates
pkill -f "playerctl --follow"

# Ensure the directory for the cover art exists (optional, but good practice)
touch /tmp/spotify_cover.jpg

# Monitor for song changes (trackid) and play/pause status
playerctl --player=spotify metadata --format '{{ mpris:trackid }} {{ status }}' --follow | while read -r _ignored_line; do
    
    STATUS=$(playerctl --player=spotify status)
    ARTIST=$(playerctl --player=spotify metadata artist)
    TITLE=$(playerctl --player=spotify metadata title)
    ART_URL=$(playerctl --player=spotify metadata mpris:artUrl)

    # Standardize the destination for the cover art
    ICON_DEST="/tmp/spotify_cover.jpg"
    
    # --- HANDLE COVER ART ---
    if [[ "$ART_URL" == http* ]]; then
        # If it's a web URL (Spotify), download it
        curl -s "$ART_URL" -o "$ICON_DEST"
    elif [[ "$ART_URL" == file* ]]; then
        # If it's a local file (MPD/VLC), copy it
        cp "${ART_URL#file://}" "$ICON_DEST"
    else
        # Fallback: remove the old image so bars don't show stale art
        rm -f "$ICON_DEST"
        # Set a generic icon name for the notification
        ICON_DEST="media-playback-start"
    fi

    # --- HANDLE TEXT & NOTIFICATION ---
    if [ "$STATUS" == "Playing" ]; then
        HEADER="Now Playing"
        # Write to file for Waybar/Eww
        echo "[ $ARTIST / $TITLE 󰎇 ]" > /tmp/spotify_text.txt
    else
        HEADER="Paused"
        # clear or update the text file when paused
        echo "Paused" > /tmp/spotify_text.txt
        
        if [ -z "$ART_URL" ]; then
            ICON_DEST="media-playback-pause"
        fi
    fi

    # --- SEND NOTIFICATION ---
    # The ID 'spotify' replaces the previous notification to prevent spam
    notify-send -a "spotify" \
                -i "$ICON_DEST" \
                -h string:x-canonical-private-synchronous:spotify \
                "$HEADER" "$ARTIST - $TITLE"

done