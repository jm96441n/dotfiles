#!/usr/bin/env bash

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR DOTFILES_CACHE DOTFILES_EXTRA_DIR
DOTFILES_DIR="$( cd "$( dirname "~/.dotfiles" )" && pwd )"
DOTFILES_CACHE="$DOTFILES_DIR/.cache.sh"
DOTFILES_EXTRA_DIR="$HOME/.extra"

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Update dotfiles itself first

if is-executable git -a -d "$DOTFILES_DIR/.git"; then git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master; fi

# Bunch of symlinks

mkdir -p ~/.config/
ln -sfv "$DOTFILES_DIR/runcom/.zshrc" ~
ln -sfv "$DOTFILES_DIR/runcom/.alacritty.yml" ~
ln -sfv "$DOTFILES_DIR/runcom/.inputrc" ~
ln -sfv "$DOTFILES_DIR/runcom/.asdfrc" ~
ln -sfv "$DOTFILES_DIR/runcom/.gemrc" ~
ln -sfv "$DOTFILES_DIR/runcom/.tmux.conf" ~
ln -sfv "$DOTFILES_DIR/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/git/.githelpers" ~
ln -sfv "$DOTFILES_DIR/git/.git-completion.bash" ~
ln -sfv "$DOTFILES_DIR/git/.gitignore_global" ~
ln -sfv "$DOTFILES_DIR/lang_defaults/.default_gems" ~
ln -sfv "$DOTFILES_DIR/lang_defaults/.default_npm_packages" ~
ln -sfv "$DOTFILES_DIR/lang_defaults/.default-python-packages" ~
ln -sfv "$DOTFILES_DIR/.vimrc" ~/.config/nvim/init.vim

# Package managers & pagkages

if [[ is-macos ]]; then
  . "$DOTFILES_DIR/install/brew.sh"
  # . "$DOTFILES_DIR/install/bash.sh"
  . "$DOTFILES_DIR/install/brew-cask.sh"
else
  . "$DOTFILES_DIR/install/apt-get.sh"
if

. "$DOTFILES_DIR/install/asdf_install.sh"
. "$DOTFILES_DIR/install/zsh_install.sh"
. "$DOTFILES_DIR/install/oh-my-zsh-install.sh"
. "$DOTFILES_DIR/install/projects.sh"

# Install extra stuff

if [ -d "$DOTFILES_EXTRA_DIR" -a -f "$DOTFILES_EXTRA_DIR/install.sh" ]; then
  . "$DOTFILES_EXTRA_DIR/install.sh"
fi
