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

install awscli
install autojump
install bzip2
install cmake
install curl
install fzf
install git
# https://github.com/tj/git-extras/blob/master/Commands.md
install git-extras
install hub
install imagemagick
install jq
install libreadline
install libreadline-dev
install libssl-dev
install neofetch
install neovim
install python3-neovim
install postgresql
install sqlite3
install libsqlite3-dev
install thefuck
install tmux
install tree
install wget
install yarn
install xz
install zlib1g-dev
install zsh-autosuggestions
