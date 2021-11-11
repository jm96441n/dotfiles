#!/bin/bash

if [ -n "$1" ]; then
  python ~/.config/rofi/launchers-git/web-search.py "$1"
  exit 0
fi

echo "Input your search term (end it with a '!' to get suggestions)"
