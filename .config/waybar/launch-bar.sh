#!/usr/bin/env bash

## Files and Directories
DIR="$HOME/.config/waybar"
CONFIG_FILE="$DIR/config"
STYLE_FILE="$DIR/style.css"
SFILE="$DIR/system.json"
RFILE="$DIR/.system"
MFILE="$DIR/.module"

## Get system variable values for various modules
get_values() {
  CARD=$(basename "$(find /sys/class/backlight/* | head -n 1)")
  BATTERY=$(basename "$(find /sys/class/power_supply/*BAT* | head -n 1)")
  ADAPTER=$(basename "$(find /sys/class/power_supply/*AC* | head -n 1)")
  INTERFACE=$(ip link | awk '/state UP/ {print $2}' | tr -d :)
}

## Write values to `system.json` file
set_values() {
  # Create system.json if it doesn't exist
  if [[ ! -f "$SFILE" ]]; then
    echo '{
  "battery": "BAT0",
  "adapter": "AC",
  "graphics_card": "intel_backlight",
  "network_interface": "wlp0s20f3"
}' >"$SFILE"
  fi

  # Update values using jq if available, or sed as fallback
  if command -v jq &>/dev/null; then
    if [[ "$ADAPTER" ]]; then
      jq --arg adapter "$ADAPTER" '.adapter = $adapter' "$SFILE" >"$SFILE.tmp" && mv "$SFILE.tmp" "$SFILE"
    fi
    if [[ "$BATTERY" ]]; then
      jq --arg battery "$BATTERY" '.battery = $battery' "$SFILE" >"$SFILE.tmp" && mv "$SFILE.tmp" "$SFILE"
    fi
    if [[ "$CARD" ]]; then
      jq --arg card "$CARD" '.graphics_card = $card' "$SFILE" >"$SFILE.tmp" && mv "$SFILE.tmp" "$SFILE"
    fi
    if [[ "$INTERFACE" ]]; then
      jq --arg interface "$INTERFACE" '.network_interface = $interface' "$SFILE" >"$SFILE.tmp" && mv "$SFILE.tmp" "$SFILE"
    fi
  else
    # Fallback to sed for systems without jq
    if [[ "$ADAPTER" ]]; then
      sed -i -e "s/\"adapter\": \".*\"/\"adapter\": \"$ADAPTER\"/g" "$SFILE"
    fi
    if [[ "$BATTERY" ]]; then
      sed -i -e "s/\"battery\": \".*\"/\"battery\": \"$BATTERY\"/g" "$SFILE"
    fi
    if [[ "$CARD" ]]; then
      sed -i -e "s/\"graphics_card\": \".*\"/\"graphics_card\": \"$CARD\"/g" "$SFILE"
    fi
    if [[ "$INTERFACE" ]]; then
      sed -i -e "s/\"network_interface\": \".*\"/\"network_interface\": \"$INTERFACE\"/g" "$SFILE"
    fi
  fi

  # Update the main config file with the correct values from system.json
  if command -v jq &>/dev/null; then
    BATTERY_VALUE=$(jq -r '.battery' "$SFILE")
    ADAPTER_VALUE=$(jq -r '.adapter' "$SFILE")
    INTERFACE_VALUE=$(jq -r '.network_interface' "$SFILE")

    # Update the main config with these values
    # This requires a more complex setup since we're editing JSON
    # For simplicity, we use sed but in a production environment
    # consider using a more robust method

    sed -i -e "s/\"bat\": \".*\"/\"bat\": \"$BATTERY_VALUE\"/g" "$CONFIG_FILE"
    sed -i -e "s/\"adapter\": \".*\"/\"adapter\": \"$ADAPTER_VALUE\"/g" "$CONFIG_FILE"
    sed -i -e "s/\"interface\": \".*\"/\"interface\": \"$INTERFACE_VALUE\"/g" "$CONFIG_FILE"
  fi
}

## Check if we need to use brightness instead of backlight
check_backlight() {
  CARD=$(basename "$(find /sys/class/backlight/* | head -n 1)")
  if [[ "$CARD" != *"intel_"* ]]; then
    if [[ ! -f "$MFILE" ]]; then
      # For Waybar, we need to modify the config JSON
      # This is a simplified approach - in reality you might want a more robust JSON parser
      if command -v jq &>/dev/null; then
        # Use jq to update the config
        jq 'del(.backlight) | . + {"brightness": .backlight}' "$CONFIG_FILE" >"$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
      else
        # Fallback to sed - this is risky for JSON but may work for simple cases
        sed -i -e 's/"backlight"/"brightness"/g' "$CONFIG_FILE"
      fi
      touch "$MFILE"
    fi
  fi
}

## Launch Waybar
launch_bar() {
  if [[ ! $(pidof waybar) ]]; then
    waybar -c "$CONFIG_FILE" -s "$STYLE_FILE" &
  else
    killall -q waybar
    # Wait until the processes have been shut down
    while pgrep -u $USER -x waybar >/dev/null; do sleep 1; done
    waybar -c "$CONFIG_FILE" -s "$STYLE_FILE" &
  fi
}

# Execute functions
if [[ ! -f "$RFILE" ]]; then
  get_values
  set_values
  touch "$RFILE"
fi

check_backlight
launch_bar
