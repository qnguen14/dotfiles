#!/usr/bin/env bash
set -euo pipefail

for cmd in fuzzel cliphist wl-copy wl-paste wtype notify-send; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing dependency: $cmd" >&2; exit 1; }
done

CLEAR_OPT="Clear History"
MENU="$(printf "%s\n%s" "$CLEAR_OPT" "$(cliphist list)")"
CHOICE="$(printf "%s\n" "$MENU" | fuzzel --dmenu --prompt="Clipboard: " --no-sort)"

case "${CHOICE:-}" in
  "$CLEAR_OPT")
    cliphist wipe
    notify-send "Clipboard" "History Cleared"
    ;;
  "")
    exit 0
    ;;
  *)
    cliphist decode <<< "$CHOICE" | wl-copy
    
    sleep 0.2
    # wtype -M ctrl -k v -m ctrl
    hyprctl dispatch sendshortcut CTRL, V, activewindow
    ;;
esac