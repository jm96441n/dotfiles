#! /usr/bin/bash

. /etc/os-release
LINUX_DIR="$DOTFILES_DIR/install/linux"
. "$LINUX_DIR/dnf.sh"
. "$LINUX_DIR/flatpak.sh"
. "$LINUX_DIR/fonts.sh"
fc-cache -fv
