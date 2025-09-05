#!/usr/bin/bash

set -eEuo pipefail
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Error: Set GITHUB_TOKEN env var"
  exit 1
fi

export DOTFILES_DIR DOTFILES_CACHE DOTFILES_EXTRA_DIR
DOTFILES_DIR="$HOME/.dotfiles"
# install nix
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

export PATH="/nix/var/nix/profiles/default/bin:$PATH"
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install

ln -sfv "$DOTFILES_DIR/.config/home-manager" "$HOME/.config/home-manager"

home-manager switch --flake ~/.config/home-manager#"$USER"

fc-cache -fv

# Package managers & pagkages
. "$DOTFILES_DIR/install/packages.sh"

mise install

if [ -n "$NEWKEY" ]; then
  . "$DOTFILES_DIR/install/autokey-github.sh"
fi

echo "GITHUB_ACCESS_TOKEN=$GITHUB_TOKEN" >"$DOTFILES_DIR/system/.private_env"
echo "GITHUB_TOKEN=$GITHUB_TOKEN" >"$DOTFILES_DIR/system/.private_env"

mkdir -p ~/.themes
if [ ! -d "$HOME/.themes/everforest-gt" ]; then
  git clone https://github.com/theory-of-everything/everforest-gtk ~/.themes/everforest-gtk
fi

# tell flatpak to use everforest-gtk theme
sudo flatpak override --filesystem="$HOME/.themes"
sudo flatpak override --env=GTK_THEME=everforest-gtk
