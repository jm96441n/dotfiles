#! /usr/bin/bash

set -eEuo pipefail

sudo apt update && sudo apt upgrade -y

function install() {
    echo "Installing: ${1}..."
    sudo apt install -y $1
}

# setup for docker
sudo mkdir -p /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# setup for kubectl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# setup helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# setup github cli
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# setup i3 for gaps
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2022.02.17_all.deb keyring.deb SHA256:52053550c4ecb4e97c48900c61b2df4ec50728249d054190e8a0925addb12fc6
sudo apt install ./keyring.deb
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list

sudo apt update

sudo apt install --reinstall ca-certificates

install awscli
install autojump
install bat
install bzip2
install cmake
install curl
install docker-ce
install docker-ce-cli
install direnv
install containerd.io
install exa
install flatpak
install feh
install fzf
install gcc
install gh
install git
# https://github.com/tj/git-extras/blob/master/Commands.md
install git-extras
install helm
install hub
install htop
install imagemagick
install i3
install i3lock
install i3status
install jq
install kubectl
install libreadline-dev
install libssl-dev
install libffi-dev
install lsb-release
install libxext-dev
install libxcb1-dev
install libxcb-damage0-dev
install libxcb-xfixes0-dev
install libxcb-shape0-dev
install libxcb-render-util0-dev
install libxcb-render0-dev
install libxcb-randr0-dev
install libxcb-composite0-dev
install libxcb-image0-dev
install libxcb-present-dev
install libxcb-xinerama0-dev
install libxcb-glx0-dev
install libpixman-1-dev
install libdbus-1-dev
install libconfig-dev
install libgl1-mesa-dev
install libpcre2-dev
install libpcre3-dev
install libevdev-dev
install uthash-dev
install libev-dev
install libx11-xcb-dev
install lxappearance
install make
install meson
install neofetch
install npm
install picom
install polybar
install postgresql
install ranger
install rofi
install sqlite3
install strace
install libsqlite3-dev
install thefuck
install silversearcher-ag
install tmux
install tree
install wget
install yarn
install xbacklight
install xclip
install xz-utils
install zlib1g-dev
install zsh-autosuggestions

echo "installed"
