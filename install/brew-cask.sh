#!/bin/bash

if ! is-macos -o ! is-executable brew; then
  echo "Skipped: Homebrew-Cask"
  return
fi

brew tap caskroom/versions
brew tap caskroom/cask
brew tap caskroom/fonts

# Install packages
 apps=(
  dropbox
  firefox
  flux
  iterm2
  lastpass
  google-chrome
  postico
  spotify
  sublime-text
  visual-studio-code
  vlc
  wavebox
 )

brew cask install "${apps[@]}"

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize webpquicklook suspicious-package qlvideo
