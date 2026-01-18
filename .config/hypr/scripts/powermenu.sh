#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# USER CONFIG
# ----------------------------

# Your Hyprland output name(s). Find with: hyprctl monitors
OUTPUTS=( "eDP-1" )

# !!! CRITICAL: Set your screen resolution and scale here !!!
# Hyprland needs these to re-apply the monitor config with the new Hz.
RESOLUTION="1920x1080"  # Example: 1920x1080, 2560x1440, etc.
SCALE="1"             # Example: 1, 1.25, 1.5, 2

# Refresh policy
HZ_ECO=60
HZ_BALANCED=60
HZ_PERFORMANCE=144  # Ensure your screen actually supports this

# Reload waybar to update modules (battery/custom scripts)
RELOAD_WAYBAR=1

# ----------------------------
# Helpers
# ----------------------------
have() { command -v "$1" >/dev/null 2>&1; }

set_refresh_all() {
  local hz="$1"
  for out in "${OUTPUTS[@]}"; do
    # Hyprland Syntax: monitor = name, resolution@hz, position, scale
    # We use 'auto' for position to avoid breaking things, but we MUST specify resolution/scale.
    hyprctl keyword monitor "$out, ${RESOLUTION}@${hz}, auto, ${SCALE}" >/dev/null 2>&1
  done
}

set_power_profile() {
  local profile="$1"
  if have powerprofilesctl; then
    powerprofilesctl set "$profile" >/dev/null 2>&1 || true
  fi
}

notify() {
  if have notify-send; then
    # -h string:x-canonical-private-synchronous:power prevents stacking notifications
    notify-send -h string:x-canonical-private-synchronous:power "Power Menu" "$1"
  fi
}

reload_waybar() {
  if [[ "$RELOAD_WAYBAR" == "1" ]]; then
    # Reload config without killing the process if possible, or restart it
    killall -SIGUSR2 waybar || (killall waybar; swaybar &)
  fi
}

# ----------------------------
# Menu
# ----------------------------
MENU="$(
  cat <<'EOF'
Lock
Logout
Sleep
Reboot
Shutdown
---------------
Eco
Balanced
Performance
EOF
)"

# grep -v '^-' removes the separator line so you can't accidentally click it
CHOICE="$(printf '%s\n' "$MENU"  | fuzzel --dmenu --prompt="Power: " --no-sort)" || exit 0

[[ -n "${CHOICE:-}" ]] || exit 0

case "$CHOICE" in
  "Lock")
    if have hyprlock; then
      hyprlock
    else
      loginctl lock-session
    fi
    ;;

  "Logout")
    hyprctl dispatch exit
    ;;

  "Sleep")
    systemctl suspend
    ;;

  "Reboot")
    systemctl reboot
    ;;

  "Shutdown")
    systemctl poweroff
    ;;
    

  "Eco")
    set_power_profile power-saver
    set_refresh_all "$HZ_ECO"
    notify "Eco: power-saver @ ${HZ_ECO}Hz"
    ;;

  "Balanced")
    set_power_profile balanced
    set_refresh_all "$HZ_BALANCED"
    notify "Balanced: balanced @ ${HZ_BALANCED}Hz"
    ;;

  "Performance")
    set_power_profile performance
    set_refresh_all "$HZ_PERFORMANCE"
    notify "Performance: performance @ ${HZ_PERFORMANCE}Hz"
    ;;

  *)
    exit 0
    ;;
esac
