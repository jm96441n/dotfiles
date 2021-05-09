sudo dnf update

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

install awscli
install alacritty
install autoconf 
install autojump
install bison
install bzip2
install docker
install cmake
install curl
install firefox
install fzf
install gcc
install git
# https://github.com/tj/git-extras/blob/master/Commands.md
install git-extras
install gdbm-devel
install hub
install htop
install ImageMagick
install jemalloc-devel
install jq
install lastpass-cli
install libyaml-devel
install libffi-devel
install make
install ncurses-devel
install neofetch
install neovim
install openssl
install openssl-devel
install python3-neovim
install postgresql
install readline
install readline-devel
install ruby
install sqlite3
install thefuck
install tmux
install tree
install wget
install xz
install zlib
install zlib-devel
install zsh-autosuggestions
