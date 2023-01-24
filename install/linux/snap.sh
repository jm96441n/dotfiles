#! /usr/bin/zsh

set -eEuo pipefail

sudo apt update && sudo apt upgrade -y

function install() {
    INSTALLED=$(snap list | grep "$1")
    if [ -n $INSTALLED ]; then
        echo "Installing: ${1}..."
        sudo snap install $1
    else
        echo "Already installed: ${1}"
    fi
}

install nvim
install chromium
install firefox
