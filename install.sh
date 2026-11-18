#!/usr/bin/bash

set -eEuo pipefail
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "Error: Set GITHUB_TOKEN env var"
  exit 1
fi

export DOTFILES_DIR DOTFILES_CACHE DOTFILES_EXTRA_DIR
DOTFILES_DIR="$HOME/.dotfiles"

# Package managers & pagkages
. "$DOTFILES_DIR/install/packages.sh"

# install nix
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

export PATH="/nix/var/nix/profiles/default/bin:$PATH"

. /home/johnmaguire/.nix-profile/etc/profile.d/nix.sh

nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install

# sudo ln -s ~/.nix-profile/share/wayland-sessions/sway.desktop /usr/share/wayland-sessions/sway-hm.desktop

home-manager switch -b backup --extra-experimental-features nix-command --extra-experimental-features flakes --flake "$DOTFILES_DIR#$USER"

fc-cache -fv

mise install

cat >"$DOTFILES_DIR/system/.private_env" <<EOF
export GITHUB_TOKEN="$GITHUB_TOKEN"
EOF
