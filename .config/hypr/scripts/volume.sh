#!/bin/bash

# $1 is the argument passed (up, down, mute, mic_toggle)
case $1 in
    up)
        pamixer -i 5
        ;;
    down)
        pamixer -d 5
        ;;
    mute)
        pamixer -t
        ;;
    mic_toggle)
        pamixer --default-source -t
        # Check Mic Status
        IS_MIC_MUTED=$(pamixer --default-source --get-mute)
        if [ "$IS_MIC_MUTED" = "true" ]; then
            notify-send -a "volume" -i "microphone-sensitivity-muted" "Microphone" "Muted"
        else
            notify-send -a "volume" -i "microphone-sensitivity-high" "Microphone" "On"
        fi
        # Exit script immediately so we don't show the Speaker volume OSD
        exit 0
        ;;
esac

# --- Speaker Volume Logic (Only runs for up/down/mute) ---

VOL=$(pamixer --get-volume)
IS_MUTED=$(pamixer --get-mute)

if [ "$IS_MUTED" = "true" ]; then
    ICON="audio-volume-muted"
    TEXT="Muted"
else
    ICON="audio-volume-high"
    TEXT="$VOL%"
fi

notify-send -a "volume" -i "$ICON" -h int:value:"$VOL" "Volume" "$TEXT"