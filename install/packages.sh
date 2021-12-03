function linux_install() {
  . /etc/os-release
  OS=$NAME
  LINUX_DIR="$DOTFILES_DIR/install/linux"
  if [[ $OS == "Ubuntu" ]]; then
    . "$LINUX_DIR/apt-get.sh"
  elif [[ $OS == "Fedora" ]]; then
    . "$LINUX_DIR/dnf.sh"
  fi
  . "$LINUX_DIR/flatpak.sh"
  . "$LINUX_DIR/fonts.sh"
  git clone https://github.com/so-fancy/diff-so-fancy.git ~/.diff-so-fancy
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

# install plug install for nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
