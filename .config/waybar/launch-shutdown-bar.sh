#!/usr/bin/env bash

## Files and Directories
DIR="$HOME/.config/waybar"
POWER_MENU_CONFIG="$DIR/powerbar.json"
POWER_MENU_STYLE="$DIR/style.css"

## Launch Waybar power menu
toggle_power_menu() {
  # Check if power menu is already running
  if pgrep -f "waybar -c $POWER_MENU_CONFIG" >/dev/null; then
    # If power menu is visible, hide it (kill only the power menu instance)
    pkill -f "waybar -c $POWER_MENU_CONFIG"
  else
    # If power menu isn't visible, show it without disturbing the main bar
    waybar -c "$POWER_MENU_CONFIG" -s "$POWER_MENU_STYLE" &
  fi
}

toggle_power_menu
