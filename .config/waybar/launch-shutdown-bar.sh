#!/usr/bin/env bash

## Files and Directories
DIR="$HOME/.config/waybar"
POWER_MENU_CONFIG="$DIR/power-menu.json"
POWER_MENU_STYLE="$DIR/power-menu-style.css"

## Launch Waybar power menu
launch_power_menu() {
  # Check if waybar is already running with main config
  if [[ $(pidof waybar) ]]; then
    # If power menu is already visible, hide it by restarting the main bar
    if pgrep -f "waybar -c $POWER_MENU_CONFIG" >/dev/null; then
      # Kill the power menu and restart the main bar
      pkill -f "waybar -c $POWER_MENU_CONFIG"
      # Restart the main waybar
      "$DIR/launch-bar.sh"
    else
      # If power menu isn't visible, show it
      # Kill all waybar instances first
      killall -q waybar
      # Wait until the processes have been shut down
      while pgrep -u $USER -x waybar >/dev/null; do sleep 1; done
      # Launch the power menu
      waybar -c "$POWER_MENU_CONFIG" -s "$POWER_MENU_STYLE" &
    fi
  else
    # If no waybar is running, just launch the power menu
    waybar -c "$POWER_MENU_CONFIG" -s "$POWER_MENU_STYLE" &
  fi
}

launch_power_menu
