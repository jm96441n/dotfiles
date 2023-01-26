#!/usr/bin/zsh

set -eEuo pipefail

sudo apt install curl

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR DOTFILES_CACHE DOTFILES_EXTRA_DIR
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_CACHE="$DOTFILES_DIR/.cache.sh"
DOTFILES_EXTRA_DIR="$HOME/.extra"

if [[ -z "${BW_CLIENTSECRET}" ]]; then
	echo "Bitwarden client secret: "
	read -n BW_CLIENTSECRET
	export BW_CLIENTSECRET="$BW_CLIENTSECRET"
fi
if [[ -z "${BW_CLIENTID}" ]]; then
	echo "Bitwarden client id: "
	read -n BW_CLIENTID
	export BW_CLIENTID="$BW_CLIENTID"
fi
if [[ -z "${BW_PASSWORD}" ]]; then
	echo "Bitwarden password: "
	read -n BW_PASSWORD
	export BW_PASSWORD="$BW_PASSWORD"
fi


# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Update dotfiles itself first

if is-executable git -a -d "$DOTFILES_DIR/.git"; then git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master; fi

mkdir -p "$HOME/i3"
mkdir -p "$HOME/.config/autorandr"
mkdir -p "$HOME/.config/k9s"

# Bunch of symlinks
ln -sfv "$DOTFILES_DIR/.config/zsh/.zshrc" $HOME
ln -sfv "$DOTFILES_DIR/.config/.inputrc" $HOME
ln -sfv "$DOTFILES_DIR/.config/tmux/.tmux.conf" $HOME
ln -sfv "$DOTFILES_DIR/.config/tmux/.tmux.conf.local" $HOME
ln -sfv "$DOTFILES_DIR/.config/tmux/.tmux-cht-commands" $HOME
ln -sfv "$DOTFILES_DIR/.config/tmux/.tmux-cht-languages" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default-gems" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default_npm_packages" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default-python-packages" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default-cargo-crates" $HOME
ln -sfv "$DOTFILES_DIR/lang_defaults/.default-golang-pkgs" $HOME
ln -sfv "$DOTFILES_DIR/.config/nvim" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/rofi" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/polybar" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/i3" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/ranger" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/compton" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/bat" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/.Xinitrc" $HOME
ln -sfv "$DOTFILES_DIR/.config/.Xresources" $HOME
ln -sfv "$DOTFILES_DIR/.config/kitty" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/jrnl" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/.tmuxinator" "$HOME/.config"
ln -sfv "$DOTFILES_DIR/.config/autorandr/postswitch" "$HOME/.config/autorandr/postswitch"
ln -sfv "$DOTFILES_DIR/.config/k9s/skin.yml" "$HOME/.config/k9s/skin.yml"

# Package managers & pagkages
#. "$DOTFILES_DIR/install/packages.sh"
#. "$DOTFILES_DIR/install/asdf_install.sh"
#. "$DOTFILES_DIR/install/autokey-github.sh"

ln -sfv "$DOTFILES_DIR/git/.gitconfig" $HOME
ln -sfv "$DOTFILES_DIR/git/.githelpers" $HOME
ln -sfv "$DOTFILES_DIR/git/.gitignore_global" $HOME

#. "$DOTFILES_DIR/install/projects.sh"

# Install extra stuff

if [ -d "$DOTFILES_EXTRA_DIR" -a -f "$DOTFILES_EXTRA_DIR/install.sh" ]; then
    . "$DOTFILES_EXTRA_DIR/install.sh"
fi


PATH="$HOME/.cargo/bin:$PATH"

# add theme for bat
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"

if [ ! -d "$(bat --config-dir)/themes/forest-night-textmate" ]; then
    # Download a theme in '.tmTheme' format, for example:
    git clone https://github.com/mhanberg/forest-night-textmate.git
fi

# Update the binary cache
bat cache --build

cd ~

mkdir -p ~/.themes
if [ ! -d "$HOME/.themes/everforest-gt" ]; then
    git clone https://github.com/theory-of-everything/everforest-gtk ~/.themes/everforest-gtk
fi

# tell flatpak to use everforest-gtk theme
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --env=GTK_THEME=everforest-gtk

echo "Installing zsh"

. "$DOTFILES_DIR/install/zsh_install.sh"

if test -f .zshrc.pre-oh-my-zsh; then
    rm .zshrc
    mv .zshrc.pre-oh-my-zsh .zshrc
fi
