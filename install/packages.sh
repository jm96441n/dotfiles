#! /usr/bin/zsh

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
    # install kitty
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # install k9s
    sudo wget -qO- https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz | tar zxvf -  -C /tmp/
    sudo mv /tmp/k9s /usr/local/bin

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
