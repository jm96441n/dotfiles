#! /usr/bin/bash

set -eEuo pipefail
sudo dnf update

#sudo dnf install

# install yarn
if [[ $(which yarn &>/dev/null) -ne 0 ]]; then
  curl -o- -L https://yarnpkg.com/install.sh | bash
fi

function install {

  if [[ $(which "$1" &>/dev/null) -ne 0 ]]; then
    echo "Installing: ${1}..."
    sudo dnf install -y "$1"
  else
    echo "Already installed: ${1}"
  fi
}
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf copr enable pgdev/ghostty

# setup kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF

# enable rpm fusion repo
install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
install ImageMagick
install aajohan-comfortaa-fonts
install acpi
install adwaita-qt6
install akmod-nvidia
install anaconda
install anaconda-install-env-deps
install anaconda-live
install ansible
install arandr
install autoconf
install autojump
install awscli
install bat
install biosdevname
install bison
install bzip2
install cairo-devel
install cairo-gobject-devel
install chkconfig
install chromium
install clang-devel
install clang-resource-filesystem
install cmake
install conky
install containerd.io
install curl
install dbus-devel
install direnv
install docker-buildx-plugin
install docker-ce
install docker-ce-cli
install docker-compose-plugin
install double-conversion
install dracut-live
install dunst
install exa
install eza
install fd-find
install fedora-workstation-repositories
install feh
install ffmpeg
install firefox
install flameshot
install fzf
install gcc
install gcc-c++
install gdbm-devel
install gh
install ghostscript-tools-fonts
install ghostscript-tools-printing
install ghostty
install git
install git-delta
install git-extras
install gnome-weather
install gobject-introspection-devel
install google-cloud-cli
install google-cloud-cli-gke-gcloud-auth-plugin
install gpg2
install grub2-efi-aa64-modules
install gtk4-devel
install haproxy
install helm
install htop
install hub
install i3
install i3lock
install i3status
install initscripts
install jemalloc-devel
install jq
install k9s
install kernel
install kernel-core
install kernel-devel
install kernel-modules
install kernel-modules-core
install kernel-modules-extra
install kitty
install kmod-nvidia
install kubectl
install langpacks-en
install libX11-devel
install libX11-xcb
install libXScrnSaver
install libXext-devel
install libadwaita-devel
install libadwaita-qt6
install libb2
install libconfig-devel
install libdrm-devel
install libev-devel
install libffi-devel
install libreoffice-data
install libreoffice-ure-common
install libvirt
install libvirt-daemon-config-network
install libvirt-daemon-kvm
install libxcb-devel
install libxml2-devel
install libyaml-devel
install lld
install lld-libs
install llvm-devel
install llvm-libs
install lm_sensors
install lxappearance
install make
install mesa-libGL-devel
install meson
install ncurses-devel
install neofetch
install neovim
install nmap
install nodejs-npm
install nordvpn
install npm
install openssl
install openssl-devel
install packer
install perl-core
install pcre-devel
install peek
install pgadmin4
install pgadmin4-fedora-repo
install picom
install pixman-devel
install polybar
install postgresql
install powertop
install proton-vpn-gnome-desktop
install protonvpn-stable-release
install python3-devel
install python3-neovim
install qemu-kvm
install qgnomeplatform-qt6
install qt6-qtbase
install qt6-qtbase-common
install qt6-qtbase-gui
install qt6-qtdeclarative
install qt6-qtsvg
install qt6-qtwayland
install ranger
install re2c
install readline
install readline-devel
install redis
install remove-retired-packages
install rofi
install rpmfusion-free-release
install rpmfusion-nonfree-release
install ruby-devel
install rust-src
install sqlite
install sqlite-devel
install strace
install tailscale
install terraform
install thefuck
install tlp
install tlp-rdw
install tmux
install tree
install tslib
install uthash-devel
install vlc
install wget
install xbacklight
install xcb-util-image-devel
install xcb-util-renderutil-devel
install xclip
install xcompmgr
install xinput
install xorg-x11-proto-devel
install xset
install xss-lock
install xz
install zig
install zlib
install zlib-devel
install zlib-ng-compat-devel
install zsh-autosuggestions
