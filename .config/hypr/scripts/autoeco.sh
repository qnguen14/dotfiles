#!/bin/bash

# --- CONFIGURATION ---
# Run 'hyprctl monitors' to find your monitor name
MONITOR="eDP-1" 

# Your Max Resolution and Refresh Rate (AC Mode)
# Format: res@hz
HIGH_RES="1920x1080@144"

# Your Eco Resolution/Refresh (Battery Mode)
# 60Hz is standard for saving battery
LOW_RES="1920x1080@60"
# ---------------------

# File that indicates charging status
# Usually ADP1, ADP0, or AC. Check /sys/class/power_supply/ if this doesn't work.
POWER_SUPPLY="/sys/class/power_supply/ACAD/online" 
# Fallback if ADP0 doesn't exist (some laptops use AC)
if [ ! -f "$POWER_SUPPLY" ]; then
    POWER_SUPPLY="/sys/class/power_supply/AC/online"
fi

# Store state to avoid spamming commands
last_state="unknown"

while true; do
    # Read the current state (1 = Plugged In, 0 = Battery)
    current_state=$(cat "$POWER_SUPPLY")

    if [ "$current_state" != "$last_state" ]; then
        if [ "$current_state" == "1" ]; then
            # --- PLUGGED IN (PERFORMANCE) ---
            echo "Power connected: Switching to Performance Mode"
            
            # 1. Set High Refresh Rate
            hyprctl keyword monitor "$MONITOR,$HIGH_RES,0x0,1"
            
            # 2. Enable "Eye Candy" (Blur, Animations, Shadows)
            hyprctl keyword decoration:blur:enabled true
            hyprctl keyword decoration:drop_shadow true
            hyprctl keyword animations:enabled true
            
            # 3. Set Power Profile (requires power-profiles-daemon)
            powerprofilesctl set performance

        else
            # --- UNPLUGGED (ECO MODE) ---
            echo "Power disconnected: Switching to Eco Mode"
            
            # 1. Set 60Hz Refresh Rate
            hyprctl keyword monitor "$MONITOR,$LOW_RES,0x0,1"
            
            # 2. Disable "Eye Candy" to save GPU power
            hyprctl keyword decoration:blur:enabled false
            hyprctl keyword decoration:drop_shadow false
            # Optional: Disable animations for max savings (uncomment if you want)
            # hyprctl keyword animations:enabled false
            
            # 3. Set Power Profile
            powerprofilesctl set power-saver
        fi
        
        # Update state
        last_state="$current_state"
    fi

    # Check again in 3 seconds
    sleep 3
done