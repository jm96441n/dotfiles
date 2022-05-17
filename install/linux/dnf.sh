sudo dnf update

sudo dnf install

# install yarn
curl -o- -L https://yarnpkg.com/install.sh | bash
function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo dnf install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

# enable i3-gaps
sudo dnf remove i3
sudo dnf copr enable fuhrmann/i3-gaps

# enable rpm fusion repo
install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
install awscli
install alacritty
install akmod-nvidia
install autoconf
install autojump
install bat
install bison
install bzip2
install dbus-devel
install docker
install rofi
install cmake
install curl
install conky
install compton
install exa
install feh
install firefox
install fzf
install gcc
install gcc-c++
install git
install gpg2
# https://github.com/tj/git-extras/blob/master/Commands.md
install git-extras
install gdbm-devel
install hub
install htop
install ImageMagick
install i3-gaps
install i3lock
install i3status
install jemalloc-devel
install jq
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
install pixman-devel
install python3-neovim
install polybar
install postgresql
install readline
install readline-devel
install sqlite3
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
install zlib
install zlib-devel
install zsh-autosuggestions


