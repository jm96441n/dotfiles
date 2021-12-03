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
curl https://baltocdn.com/i3-window-manager/signing.asc | sudo apt-key add -
sudo apt install apt-transport-https --yes
echo "deb https://baltocdn.com/i3-window-manager/i3/i3-autobuild-ubuntu/ all main" | sudo tee /etc/apt/sources.list.d/i3-autobuild.list

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
install silversearcher-ag
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

sudo apt install --reinstall ca-certificates
