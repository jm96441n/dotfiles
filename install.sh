#!/usr/bin/bash

set -eEuo pipefail

# sudo  install curl

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR DOTFILES_CACHE DOTFILES_EXTRA_DIR
DOTFILES_DIR="$HOME/.dotfiles"

if [[ -z "${BW_CLIENTSECRET}" ]]; then
  echo "Bitwarden client secret: "
  read -n BW_CLIENTSECRET
  export BW_CLIENTSECRET="$BW_CLIENTSECRET"
fi
if [[ -z "${BW_CLIENTID}" ]]; then
  echo "Bitwarden client id: "
  read -n BW_CLIENTID
  export BW_CLIENTID="$BW_CLIENTID"
fi
if [[ -z "${BW_PASSWORD}" ]]; then
  echo "Bitwarden password: "
  read -n BW_PASSWORD
  export BW_PASSWORD="$BW_PASSWORD"
fi

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Update dotfiles itself first

if is-executable git -a -d "$DOTFILES_DIR/.git"; then git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master; fi

# Bunch of symlinks
ln -sfv "$DOTFILES_DIR/.config/k9s/skin.yml" "$HOME/.config/k9s/skins/everforest-dark.yaml"
ln -sfv "$DOTFILES_DIR/.config/k9s/config.yml" "$HOME/.config/k9s/config.yaml"
ln -sfv "$DOTFILES_DIR/.config/k9s/views.yml" "$HOME/.config/k9s/views.yaml"

# Package managers & pagkages
. "$DOTFILES_DIR/install/packages.sh"
. "$DOTFILES_DIR/install/mise.sh"
if [ ! -z "$NEWKEY" ]; then
  . "$DOTFILES_DIR/install/autokey-github.sh"
else
  . "$DOTFILES_DIR/install/pull-ssh-keys.sh"
fi

ln -sfv "$DOTFILES_DIR/git/.githelpers" "$HOME"

. "$DOTFILES_DIR/install/projects.sh"

# Install extra stuff

PATH="$HOME/.cargo/bin:$PATH"

mkdir -p ~/.themes
if [ ! -d "$HOME/.themes/everforest-gt" ]; then
  git clone https://github.com/theory-of-everything/everforest-gtk ~/.themes/everforest-gtk
fi

# tell flatpak to use everforest-gtk theme
sudo flatpak override --filesystem="$HOME/.themes"
sudo flatpak override --env=GTK_THEME=everforest-gtk
