sudo dnf update
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo

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
install autojump
install bzip2
install docker
install cmake
install curl
install firefox
install fzf
install git
# https://github.com/tj/git-extras/blob/master/Commands.md
install git-extras
install hub
install htop
install ImageMagick
install jq
install lastpass-cli
install neofetch
install neovim
install openssl
install python3-neovim
install postgresql
install readline
install sqlite3
install thefuck
install tmux
install tree
install wget
install yarn
install xz
install zlib
install zsh-autosuggestions
