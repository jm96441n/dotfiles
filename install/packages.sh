function linux_install() {
  . /etc/os-release
  OS=$NAME
  LINUX_DIR="$DOTFILES_DIR/install/linux"
  if [[ $OS == *"Ubuntu"* ]]; then
    . "$LINUX_DIR/apt-get.sh"
  elif [[ $OS == *"Fedora"* ]]; then
    . "$LINUX_DIR/dnf.sh"
  fi
  . "$LINUX_DIR/flatpak.sh"
  . "$LINUX_DIR/fonts.sh"
  fc-cache -fv
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

# install kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# install neovim as app image
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage
