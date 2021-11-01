if ! is-macos -o ! is-executable ruby -o ! is-executable curl -o ! is-executable git; then
  echo "Skipped: Homebrew (missing: ruby, curl and/or git)"
  return
fi
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
brew upgrade

apps=(
  autojump
  cheatsheet
  cmake
  coreutils
  diff-so-fancy
  fzf
  git
  # https://github.com/tj/git-extras/blob/master/Commands.md
  git-extras
  grep
  gpg2
  geckodriver
  hub
  imagemagick
  jq
  lazydocker
  mysql
  neofetch
  neovim
  postgis
  postgresql
  readline
  ssh-copy-id
  the_silver_searcher
  thefuck
  tmux
  tree
  unar
  wifi-password
  wget
  yarn
  xz
  zsh-autosuggestions
)

brew install "${apps[@]}"

export DOTFILES_BREW_PREFIX_COREUTILS=`brew --prefix coreutils`
set-config "DOTFILES_BREW_PREFIX_COREUTILS" "$DOTFILES_BREW_PREFIX_COREUTILS" "$DOTFILES_CACHE"
