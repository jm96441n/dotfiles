sudo apt update

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

# set up i3
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2021.02.02_all.deb keyring.deb SHA256:cccfb1dd7d6b1b6a137bb96ea5b5eef18a0a4a6df1d6c0c37832025d2edaa710
dpkg -i ./keyring.deb
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" >> /etc/apt/sources.list.d/sur5r-i3.list

# setup i3-gaps
sudo add-apt-repository -y ppa:regolith-linux/stable

install awscli
install autojump
install bzip2
install cmake
install curl
install docker
install exa
install flatpak
install feh
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
install imagemagick
install i3-gaps
install i3lock
install i3status
install jemalloc-devel
install jq
install libreadline
install libreadline-dev
install libssl-dev
install libffi-devel
install libXScrnSaver
install make
install neofetch
install neovim
install npm
install polybar
install postgresql
install sqlite3
install strace
install libsqlite3-dev
install thefuck
install the_silver_searcher
install tmux
install tree
install wget
install yarn
install xbacklight
install xclip
install xz
install zlib
install zlib-devel
install zsh-autosuggestions
