#!/usr/bin/bash

set -eEuo pipefail
if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Error: Set GITHUB_TOKEN env var"
	exit 1
fi

export DOTFILES_DIR DOTFILES_CACHE DOTFILES_EXTRA_DIR
DOTFILES_DIR="$HOME/.dotfiles"

# Package managers & pagkages
. "$DOTFILES_DIR/install/packages.sh"

# install nix
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

export PATH="/nix/var/nix/profiles/default/bin:$PATH"

. /home/johnmaguire/.nix-profile/etc/profile.d/nix.sh

nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install

# remove some stuff we're going to put back on our own
rm -r "$HOME/.config/home-manager"

ln -sfv "$DOTFILES_DIR/.config/home-manager" "$HOME/.config"

home-manager switch -b backup --extra-experimental-features nix-command --extra-experimental-features flakes --flake ~/.config/home-manager#"$USER"

fc-cache -fv

echo "NEW KEY IS $NEWKEY"
if [ -n "$NEWKEY" ]; then
	. "$DOTFILES_DIR/install/autokey-github.sh"
fi

mise install

echo "GITHUB_ACCESS_TOKEN=$GITHUB_TOKEN" >"$DOTFILES_DIR/system/.private_env"
echo "GITHUB_TOKEN=$GITHUB_TOKEN" >"$DOTFILES_DIR/system/.private_env"
