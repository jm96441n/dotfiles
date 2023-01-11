sudo apt update

function install {
  which $1 &>/dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 361FA511F8F5E4DE

# setup for docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update

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
install git
# https://github.com/tj/git-extras/blob/master/Commands.md
install git-extras
install hub
install htop
install imagemagick
install i3
install i3lock
install i3status
install jq
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
install neovim
install npm
install picom
install polybar
install postgresql
install ranger
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
install xz
install zlib1g-dev
install zsh-autosuggestions

sudo apt install --reinstall ca-certificates
