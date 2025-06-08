#! /usr/bin/bash

set -eEuo pipefail

mkdir -p ~/.themes
if [ ! -d "$HOME/.themes/everforest-gt" ]; then
  git clone https://github.com/theory-of-everything/everforest-gtk ~/.themes/everforest-gtk
fi

# tell flatpak to use everforest-gtk theme
sudo flatpak override --filesystem="$HOME/.themes"
sudo flatpak override --env=GTK_THEME=everforest-gtk
