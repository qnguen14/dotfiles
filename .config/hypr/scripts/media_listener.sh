#!/bin/bash

# Ensure we kill any old instances of this script to prevent duplicates
# (Useful if you reload hyprland config)
pkill -f "playerctl --follow"

# Wait for Spotify to be available (optional, prevents immediate exit if Spotify isn't open)
# while ! pgrep -x "spotify" > /dev/null; do sleep 5; done

# The --follow flag waits for changes. 
# We monitor {{ mpris:trackid }} (song change) and {{ status }} (play/pause)
playerctl --player=spotify metadata --format '{{ mpris:trackid }} {{ status }}' --follow | while read -r _ignored_line; do
    
    # === REUSE YOUR NOTIFICATION LOGIC ===
    
    STATUS=$(playerctl --player=spotify status)
    ARTIST=$(playerctl --player=spotify metadata artist)
    TITLE=$(playerctl --player=spotify metadata title)
    ART_URL=$(playerctl --player=spotify metadata mpris:artUrl)

    # Define the icon path
    ICON_PATH="/tmp/spotify_cover.jpg"

    # Download Art
    if [[ "$ART_URL" == http* ]]; then
        curl -s "$ART_URL" -o "$ICON_PATH"
    elif [[ "$ART_URL" == file* ]]; then
        ICON_PATH="${ART_URL#file://}"
    else
        # Fallback icons based on status
        if [ "$STATUS" == "Playing" ]; then
             ICON_PATH="media-playback-start"
        else
             ICON_PATH="media-playback-pause"
        fi
    fi

    # Determine Header
    if [ "$STATUS" == "Playing" ]; then
        HEADER="Now Playing"
    else
        HEADER="Paused"
    fi

    # === SEND NOTIFICATION ===
    # IMPORTANT: I added '-h string:x-canonical-private-synchronous:spotify'
    # This ID tells the notification server to REPLACE the old notification 
    # instead of stacking them up (preventing spam when skipping tracks).
    notify-send -a "spotify" \
                -i "$ICON_PATH" \
                -h string:x-canonical-private-synchronous:spotify \
                "$HEADER" "$ARTIST - $TITLE"

done