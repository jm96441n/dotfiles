#! /usr/bin/zsh

function linux_install() {
    . /etc/os-release
    OS=$NAME
    LINUX_DIR="$DOTFILES_DIR/install/linux"
    if [[ $OS == *"Ubuntu"* ]]; then
        . "$LINUX_DIR/apt-get.sh"
        . "$LINUX_DIR/snap.sh"
    elif [[ $OS == *"Fedora"* ]]; then
        . "$LINUX_DIR/dnf.sh"
    fi
    . "$LINUX_DIR/flatpak.sh"
    . "$LINUX_DIR/fonts.sh"
    fc-cache -fv
    # install kitty
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    mkdir -p ~/.local/bin
    # Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in your system-wide PATH)
    ln -sfv ~/.local/kitty.app/bin/kitty ~/.local/bin/
    # Place the kitty.desktop file somewhere it can be found by the OS
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
    # Update the paths to the kitty and its icon in the kitty.desktop file(s)
    sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

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
