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

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 361FA511F8F5E4DE

# setup i3-gaps
sudo add-apt-repository -y ppa:regolith-linux/stable

# setup for alacritty
sudo add-apt-repository ppa:mmstick76/alacritty

# setup for docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


install alacritty
install awscli
install autojump
install bat
install bzip2
install cmake
install curl
install docker-ce
install docker-ce-cli
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
install i3-gaps
install i3lock
install i3status
install jq
install libreadline-dev
install libssl-dev
install libffi-dev
install lsb-release
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
install zlib1g-dev
install zsh-autosuggestions

sudo apt install --reinstall ca-certificates

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
