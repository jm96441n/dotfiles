#!/usr/bin/env bash

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR DOTFILES_CACHE DOTFILES_EXTRA_DIR
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_CACHE="$DOTFILES_DIR/.cache.sh"
DOTFILES_EXTRA_DIR="$HOME/.extra"

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Update dotfiles itself first

if is-executable git -a -d "$DOTFILES_DIR/.git"; then git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master; fi

mkdir -p "$HOME/i3"

# Bunch of symlinks
ln -sfv "$DOTFILES_DIR/runcom/.zshrc" $HOME
ln -sfv "$DOTFILES_DIR/runcom/.p10k.zsh" $HOME
ln -sfv "$DOTFILES_DIR/runcom/.alacritty.yml" $HOME
ln -sfv "$DOTFILES_DIR/runcom/.inputrc" $HOME
ln -sfv "$DOTFILES_DIR/runcom/.asdfrc" $HOME
ln -sfv "$DOTFILES_DIR/runcom/.gemrc" $HOME
ln -sfv "$DOTFILES_DIR/runcom/.tmux.conf" $HOME
ln -sfv "$DOTFILES_DIR/git/.gitconfig" $HOME
ln -sfv "$DOTFILES_DIR/git/.githelpers" $HOME
ln -sfv "$DOTFILES_DIR/git/.git-completion.bash" $HOME
ln -sfv "$DOTFILES_DIR/git/.gitignore_global" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default-gems" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default_npm_packages" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default-python-packages" $HOME
ln -sfv "$DOTFILES_DIR/.config/nvim" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/rofi" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/polybar" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/i3" "$HOME/.config"

# Package managers & pagkages
. "$DOTFILES_DIR/install/packages.sh"
. "$DOTFILES_DIR/install/asdf_install.sh"
. "$DOTFILES_DIR/install/projects.sh"

# Install extra stuff

if [ -d "$DOTFILES_EXTRA_DIR" -a -f "$DOTFILES_EXTRA_DIR/install.sh" ]; then
  . "$DOTFILES_EXTRA_DIR/install.sh"
fi

echo "Installing zsh"

. "$DOTFILES_DIR/install/zsh_install.sh"

if ! test -f .zshrc.pre-oh-my-zsh; then
  rm ~/.zshrc
  mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
fi

