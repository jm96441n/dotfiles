# Dotfiles!
This is a collection of useful functions, aliases, and git configurations.

## Packages Included
### Linux
  * Core
    * [i3](https://i3wm.org/) + [i3-gaps](https://github.com/Airblader/i3) + [polybar](https://github.com/polybar/polybar) + [rofi](https://github.com/davatorium/rofi) + [picom](https://github.com/yshui/picom)
    * [ZSH](https://www.zsh.org/) + [Oh-My-ZSH](https://ohmyz.sh/) + [Powerline10k](https://github.com/romkatv/powerlevel10k)
    * [kitty](https://sw.kovidgoyal.net/kitty/)
    * [neovim](https://neovim.io/)
  * Terminal Utilities (for full list see [dnf](./install/linux/dnf.sh), [apt-get](./install/linux/apt-get.sh),
    [brew](./install/macos/brew.sh) and [brew-cask](./install/macos/brew-cask.sh) for full lists)
    * [Ag The Silver Search](https://github.com/ggreer/the_silver_searcher)
    * [asdf](https://asdf-vm.com/)
    * [Autojump](https://github.com/wting/autojump)
    * [awscli](https://aws.amazon.com/cli/)
    * [bat](https://github.com/sharkdp/bat)
    * [curl](https://curl.se/)
    * [docker](https://www.docker.com/)
    * [exa](https://github.com/ogham/exa)
    * GNU [grep](https://www.gnu.org/software/grep/)
    * [make](https://man7.org/linux/man-pages/man1/make.1.html)
    * [ranger](https://github.com/ranger/ranger)
    * [tmux](https://github.com/tmux/tmux/wiki) + [tmuxinator](https://github.com/tmuxinator/tmuxinator)
    * [Wget](https://www.gnu.org/software/wget/)

### MacOS
  * Core
    * [ZSH](https://www.zsh.org/) + [Oh-My-ZSH](https://ohmyz.sh/) + [Powerline10k](https://github.com/romkatv/powerlevel10k)
    * [Homebrew](https://brew.sh/) + [Homebrew Cask](https://caskroom.github.io/)
    * [kitty](https://sw.kovidgoyal.net/kitty/) + [tmux](https://github.com/tmux/tmux/wiki) + [tmuxinator](https://github.com/tmuxinator/tmuxinator)
    * [Ag The Silver Search](https://github.com/ggreer/the_silver_searcher) GNU [grep](https://www.gnu.org/software/grep/), [Wget](https://www.gnu.org/software/wget/)
    * [neovim](https://neovim.io/)
    * [Autojump](https://github.com/wting/autojump)
    * [tree](http://mama.indstate.edu/users/ice/tree/), [MySQL](https://www.mysql.com/), [PostgreSQL](https://www.postgresql.org/), [thefuck](https://github.com/nvbn/thefuck)
    * [imagemagick](https://www.imagemagick.org/)
    * [unar](https://theunarchiver.com/command-line)
    * [asdf](https://github.com/asdf-vm/asdf) (Ruby 3.1.0, Python 3.9.0, Go 1.18.2, NodeJS 18.5.0)
  * macOS: [Quick Lookup plugins](https://github.com/sindresorhus/quick-look-plugins)
  * [macOS apps](https://github.com/jm96441n/dotfiles/install/brew-cask.sh)


## Install

### Fedora
### Ubuntu

### MacOS
On a clean macOS installation:
```
sudo softwareupdate -i -a
xcode-select --install
```
#### Clone with Git
```
git clone https://github.com/jm96441n/dotfiles.git ~/.dotfiles
source ~/.dotfiles/install.sh
```

## The `dotfiles` command
```
$ dotfiles help
Usage: dotfiles <command>

Commands:
   clean            Clean up caches (brew, gem)
   edit             Open dotfiles in IDE (code) and Git GUI (stree)
   help             This help message
   update           Update packages and pkg managers (OS, brew, gem)
```

## Credits

The [dotfiles community](https://dotfiles.github.io) and [webpro](https://github.com/webpro/dotfiles) who I've adapted these from
