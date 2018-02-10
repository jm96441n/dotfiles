# Dotfiles!
This is a collection of useful functions, aliases, and git configurations.

## Packages Included
  * Core
    * Bash + (coreutils)[https://en.wikipedia.org/wiki/GNU_Core_Utilities] + bash-completion
    * (Homebrew)[https://brew.sh/] + (Homebrew Cask)[https://caskroom.github.io/)
    * GNU (grep)[https://www.gnu.org/software/grep/], (Wget)[https://www.gnu.org/software/wget/]
    * (tree)[http://mama.indstate.edu/users/ice/tree/], (MySQL)[https://www.mysql.com/], (PostgreSQL)[https://www.postgresql.org/], (thefuck)[https://github.com/nvbn/thefuck]
    * (unar)[https://theunarchiver.com/command-line)
    * (asdf)[https://github.com/asdf-vm/asdf) (Ruby 2.5.0)
    * Python 2
  * macOS: (Quick Lookup plugins)[https://github.com/sindresorhus/quick-look-plugins]
  * (macOS apps)[https://github.com/jm96441n/dotfiles/install/brew-cask.sh]


## Install

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
   clean            Clean up caches (brew, npm, gem, rvm)
   dock             Apply macOS Dock settings
   edit             Open dotfiles in IDE (code) and Git GUI (stree)
   help             This help message
   macos            Apply macOS system defaults
   update           Update packages and pkg managers (OS, brew, npm, gem)
```

## Credits

The (dotfiles community)[https://dotfiles.github.io/] and (webpro)[https://github.com/webpro/dotfiles] who I've adapted these from
