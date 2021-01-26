#!/bin/bash

if ! is-macos -o ! is-executable brew; then
  echo "Skipped: Homebrew-Cask"
  return
fi

brew tap homebrew/cask
brew tap homebrew/cask-fonts

# Install packages
 apps=(
  alacritty
  alfred
  franz
  postico
  spotify
  spectacle
  spotify
  visual-studio-code
  vlc
 )

brew cask install "${apps[@]}"

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize webpquicklook suspicious-package qlvideo firefox google-chrome

# Install fonts
fonts=(
  font-fira-code-nerd-font
  font-hack-nerd-font
  font-roboto-mono-nerd-font
  font-space-mono-nerd-font
  font-meslo-lg-nerd-font
)

brew cask install "${fonts[@]}"
