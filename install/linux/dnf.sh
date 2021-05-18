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

# enable albert to be installed
sudo rpm --import "https://build.opensuse.org/projects/home:manuelschneid3r/public_key"
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:manuelschneid3r/Fedora_33/home:manuelschneid3r.repo

# enable i3-gaps
sudo dnf remove i3
sudo dnf copr enable fuhrmann/i3-gaps

# enable rpm fusion repo
install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
install albert
install awscli
install alacritty
install autoconf
install autojump
install bison
install bzip2
install docker
install rofi
install cmake
install curl
install conky
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
install lastpass-cli
install libyaml-devel
install libffi-devel
install libXScrnSaver
install make
install ncurses-devel
install neofetch
install npm
install neovim
install openssl
install openssl-devel
install python3-neovim
install polybar
install postgresql
install readline
install readline-devel
install ruby
install sqlite3
install the_silver_searcher
install thefuck
install tmux
install tree
install wget
install xz
install xbacklight
install zlib
install zlib-devel
install zsh-autosuggestions

