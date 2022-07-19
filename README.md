# Dotfiles!
This is a collection of useful functions, aliases, git configurations, and easy setup of a new machine.

## Packages Included
### Linux
  * Core
    * [i3](https://i3wm.org/) + [i3-gaps](https://github.com/Airblader/i3) + [polybar](https://github.com/polybar/polybar) + [rofi](https://github.com/davatorium/rofi) + [picom](https://github.com/yshui/picom)
    * [ZSH](https://www.zsh.org/) + [Oh-My-ZSH](https://ohmyz.sh/) + [starship.rs](https://starship.rs/)
    * [kitty](https://sw.kovidgoyal.net/kitty/)
    * [neovim](https://neovim.io/)
  * Terminal Utilities (for full list see [dnf](./install/linux/dnf.sh), [apt-get](./install/linux/apt-get.sh))
    * [Ag The Silver Search](https://github.com/ggreer/the_silver_searcher)
    * [asdf](https://asdf-vm.com/)
    * [Autojump](https://github.com/wting/autojump)
    * [awscli](https://aws.amazon.com/cli/)
    * [bat](https://github.com/sharkdp/bat)
    * [curl](https://curl.se/)
    * [docker](https://www.docker.com/)
    * [exa](https://github.com/ogham/exa)
    * [fzf](https://github.com/junegunn/fzf)
    * GNU [grep](https://www.gnu.org/software/grep/)
    * [make](https://man7.org/linux/man-pages/man1/make.1.html)
    * [ranger](https://github.com/ranger/ranger)
    * [tmux](https://github.com/tmux/tmux/wiki) + [tmuxinator](https://github.com/tmuxinator/tmuxinator)
    * [Wget](https://www.gnu.org/software/wget/)
  * Flatpak Apps
    * [Ferdium](https://ferdium.org/)
    * [Spotify](https://open.spotify.com/)
    * [Signal](https://signal.org/en/)
    * [Zoom](https://zoom.us/)
    * [Bitwarden](https://bitwarden.com/)

### MacOS
  * Core
    * [ZSH](https://www.zsh.org/) + [Oh-My-ZSH](https://ohmyz.sh/)  + [starship.rs](https://starship.rs/)
    * [Homebrew](https://brew.sh/) + [Homebrew Cask](https://caskroom.github.io/)
    * [kitty](https://sw.kovidgoyal.net/kitty/) + [tmux](https://github.com/tmux/tmux/wiki) + [tmuxinator](https://github.com/tmuxinator/tmuxinator)
    * [neovim](https://neovim.io/)
  * Terminal Utilities (for full list see [brew](./install/macos/brew.sh))
    * [Ag The Silver Search](https://github.com/ggreer/the_silver_searcher) GNU [grep](https://www.gnu.org/software/grep/), [Wget](https://www.gnu.org/software/wget/)
    * [asdf](https://asdf-vm.com/)
    * [Autojump](https://github.com/wting/autojump)
    * [awscli](https://aws.amazon.com/cli/)
    * [bat](https://github.com/sharkdp/bat)
    * [curl](https://curl.se/)
    * [docker](https://www.docker.com/)
    * [exa](https://github.com/ogham/exa)
    * [fzf](https://github.com/junegunn/fzf)
    * GNU [grep](https://www.gnu.org/software/grep/)
    * [imagemagick](https://www.imagemagick.org/)
    * [make](https://man7.org/linux/man-pages/man1/make.1.html)
    * [ranger](https://github.com/ranger/ranger)
    * [tmux](https://github.com/tmux/tmux/wiki) + [tmuxinator](https://github.com/tmuxinator/tmuxinator)
    * [tree](http://mama.indstate.edu/users/ice/tree/), [MySQL](https://www.mysql.com/), [PostgreSQL](https://www.postgresql.org/), [thefuck](https://github.com/nvbn/thefuck)
    * [Wget](https://www.gnu.org/software/wget/)
    * [unar](https://theunarchiver.com/command-line)
  * macOS: [Quick Lookup plugins](https://github.com/sindresorhus/quick-look-plugins)
  * [macOS apps](https://github.com/jm96441n/dotfiles/install/brew-cask.sh)

### Languages Included (via asdf)
  * Go 1.18.2
  * Python 3.10.4
  * Ruby 3.1.0
  * NodeJS 18.5.0

## Install

1. Ensure your system is up to date
  * Fedora
  ```
    sudo dnf upgrade
  ```
  * Ubuntu
  ```
    sudo apt-get update
  ```
  * MacOS
  ```
    sudo softwareupdate -i -a
    xcode-select --install
  ```
2. Clone with Git
  git clone https://github.com/jm96441n/dotfiles.git ~/.dotfiles

3. Run the installation script

Note: this assumes you have a bitwarden account as there are secrets that are sourced from bitwarden during the setup
```
source ~/.dotfiles/install.sh
```

## The `dotfiles` command
```
$ dotfiles help
Usage: dotfiles <command>

Commands:
   clean            Clean up caches (apt/dnf, asdf, gem)
   edit             Open dotfiles in vim
   help             This help message
   update           Update packages and pkg managers (packages, pip, gem, asdf)
```

## Credits

The [dotfiles community](https://dotfiles.github.io) and [webpro](https://github.com/webpro/dotfiles) who I've adapted these from
