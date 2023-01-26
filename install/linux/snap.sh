#! /usr/bin/zsh

set -eEuo pipefail

function install() {
    echo "Installing: ${1}..."
    sudo snap install $1
}

install nvim
install chromium
install firefox
