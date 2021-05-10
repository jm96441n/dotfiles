function linux_install() {
  . /etc/os-release
  OS=$NAME
  if [[ $OS == "Ubuntu" ]]; then
    . "$DOTFILES_DIR/install/linux/apt-get.sh"
  elif [[ $OS == "Fedora" ]]; then
    . "$DOTFILES_DIR/install/linux/dnf.sh"
    . "$DOTFILES_DIR/install/linux/flatpak.sh"
  fi
}

function macos_install() {
  . "$DOTFILES_DIR/install/macos/brew.sh"
  . "$DOTFILES_DIR/install/macos/brew-cask.sh"
}

if [[ $(is-macos) == 0 ]]; then
  macos_install
else
  linux_install
fi
