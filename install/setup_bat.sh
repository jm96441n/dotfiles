#! /usr/bin/bash

set -eEuo pipefail

# add theme for bat
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"

if [ ! -d "$(bat --config-dir)/themes/forest-night-textmate" ]; then
  # Download a theme in '.tmTheme' format, for example:
  git clone https://github.com/mhanberg/forest-night-textmate.git
fi

# Update the binary cache
bat cache --build
