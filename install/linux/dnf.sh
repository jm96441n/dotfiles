#! /usr/bin/bash

set -eEuo pipefail
sudo dnf update

sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine

# enable rpm fusion repo
install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install -y kernel kernel-core kernel-devel kernel-modules
sudo dnf install -y akmod-nvidia kmod-nvidia
sudo dnf install -y biosdevname

sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo dnf install -y docker-buildx-plugin docker-compose-plugin
sudo dnf install -y libvirt libvirt-daemon-config-network libvirt-daemon-kvm
sudo dnf install -y qemu-kvm

sudo dnf install -y chkconfig initscripts
sudo dnf install -y dracut-live
sudo dnf install -y grub2-efi-aa64-modules
sudo dnf install -y remove-retired-packages

sudo dnf install -y tlp tlp-rdw
sudo dnf install -y acpi
sudo dnf install lm-sensors

sudo dnf install -y aajohan-comfortaa-fonts
sudo dnf install -y langpacks-en

# Development libraries that need system integration - KEEP WITH DNF
sudo dnf install -y libX11-devel libX11-xcb libXext-devel libxcb-devel
sudo dnf install -y cairo-devel cairo-gobject-devel
sudo dnf install -y gtk4-devel libadwaita-devel
sudo dnf install -y mesa-libGL-devel libdrm-devel
sudo dnf install -y python3-devel ruby-devel
sudo dnf install -y ncurses-devel readline-devel
sudo dnf install -y libffi-devel libyaml-devel gdbm-devel
sudo dnf install -y zlib-devel sqlite-devel openssl-devel
