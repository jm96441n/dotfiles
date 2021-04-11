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

apps=(
  awscli
  autojump
  curl
  fzf
  git
  # https://github.com/tj/git-extras/blob/master/Commands.md
  git-extras
  geckodriver
  hub
  imagemagick
  jq
  lazydocker
  neofetch
  neovim
  python-neovim
  python3-neovim
  postgresql
  readline
  thefuck
  tmux
  tree
  wget
  yarn
  xz
  zsh-autosuggestions
)

install "${apps[@]}"
