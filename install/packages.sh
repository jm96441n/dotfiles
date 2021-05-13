function linux_install() {
  . /etc/os-release
  OS=$NAME
  LINUX_DIR="$DOTFILES_DIR/install/linux"
  if [[ $OS == "Ubuntu" ]]; then
    . "$LINUX_DIR/apt-get.sh"
  elif [[ $OS == "Fedora" ]]; then
    . "$LINUX_DIR/dnf.sh"
    . "$LINUX_DIR/flatpak.sh"
    git clone https://github.com/so-fancy/diff-so-fancy.git ~/.diff-so-fancy
  fi
  . "$LINUX_DIR/fonts.sh"
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
