#! /usr/bin/zsh

set -eEuo pipefail
sudo dnf update

sudo dnf install

# install yarn
curl -o- -L https://yarnpkg.com/install.sh | bash
function install {
    which "$1" &>/dev/null

    if [ $? -ne 0 ]; then
        echo "Installing: ${1}..."
        sudo dnf install -y "$1"
    else
        echo "Already installed: ${1}"
    fi
}

# enable i3-gaps
sudo dnf remove i3
sudo dnf copr enable fuhrmann/i3-gaps
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

# setup kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# setup github cli
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# enable rpm fusion repo
install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
install awscli
install alacritty
install akmod-nvidia
install autoconf
install autojump
install bat
install bison
install bzip2
install dbus-devel
install docker-ce
install docker-ce-cli
install containerd.io
install docker-compose-plugin
install direnv
install dunst
install rofi
install cmake
install curl
install conky
install exa
install feh
install firefox
install fd-find
install fzf
install gh
install gcc
install gcc-c++
install git
install git-delta
install gpg2
# https://github.com/tj/git-extras/blob/master/Commands.md
install git-extras
install gdbm-devel
install helm
install hub
install htop
install ImageMagick
install i3-gaps
install i3lock
install i3status
install jemalloc-devel
install jq
install kubectl
install libconfig-devel
install libffi-devel
install libdrm-devel
install libev-devel
install libX11-devel
install libX11-xcb
install libXext-devel
install libxcb-devel
install libXScrnSaver
install libyaml-devel
install lxappearance
install make
install mesa-libGL-devel
install meson
install ncurses-devel
install neofetch
install npm
install neovim
install openssl
install openssl-devel
install pcre-devel
install picom
install pixman-devel
install python3-neovim
install polybar
install postgresql
install ranger
install readline
install readline-devel
install sqlite
install sqlite-devel
install strace
install the_silver_searcher
install thefuck
install tmux
install tree
install uthash-devel
install wget
install xbacklight
install xcb-util-image-devel
install xcb-util-renderutil-devel
install xorg-x11-proto-devel
install xz
install xclip
install xinput
install xset
install xss-lock
install zlib
install zlib-devel
install zsh-autosuggestions
