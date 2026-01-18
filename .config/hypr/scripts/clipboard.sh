#!/usr/bin/env bash
set -euo pipefail

# Requirements
for cmd in fuzzel cliphist wl-copy wl-paste; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing dependency: $cmd" >&2; exit 1; }
done

# Config
MAX_ITEMS=200

# Build menu
MENU="$(cliphist list | head -n "$MAX_ITEMS")"

# If empty history, exit quietly
[[ -n "${MENU}" ]] || exit 0

CHOICE="$(
  printf '%s\n' "$MENU" \
  | fuzzel --dmenu --prompt="Clipboard: " --no-sort
)"

[[ -n "${CHOICE:-}" ]] || exit 0

# --- FIX START ---
# Use 'read' to split by whitespace (defaults to tab/space).
# This safely isolates the numeric ID into the $ID variable.
read -r ID _ <<< "$CHOICE"
# --- FIX END ---

# Safety: ID should be numeric
[[ "$ID" =~ ^[0-9]+$ ]] || { echo "Invalid ID: $ID"; exit 1; }

# Decode chosen entry and copy to clipboard.
cliphist decode "$ID" | wl-copy