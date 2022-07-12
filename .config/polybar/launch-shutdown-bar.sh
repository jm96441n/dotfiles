#!/usr/bin/env bash

## Files and Directories
DIR="$HOME/.config/polybar"
SFILE="$DIR/system"
RFILE="$DIR/.system"
MFILE="$DIR/.module"

## Launch Polybar with selected style
launch_bar() {
  if [[ $(pidof polybar) && $(pidof polybar | wc -w) -lt 2 ]]; then
    polybar -q power -c "$DIR"/config &
  else
    polybar-msg -p $(xprop -name "polybar-power_DP-2" _NET_WM_PID | cut -d ' ' -f 3) cmd toggle
    polybar-msg -p $(xprop -name "polybar-power_HDMI-1" _NET_WM_PID | cut -d ' ' -f 3) cmd toggle
  fi
}

launch_bar
