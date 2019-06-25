
if ! is-macos -o ! is-executable ruby -o ! is-executable curl -o ! is-executable git; then
  echo "Skipped: Homebrew (missing: ruby, curl and/or git)"
  return
fi

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update
brew upgrade

apps=(
  bash-completion2
  coreutils
  diff-so-fancy
  git
  # https://github.com/tj/git-extras/blob/master/Commands.md
  git-extras
  grep
  geckodriver
  hub
  imagemagick
  jq
  mysql
  postgis
  postgresql
  python
  readline
  ssh-copy-id
  thefuck
  unar
  tree
  wifi-password
  wget
  yarn
  tmux
  neovim
  fzf
  the_silver_searcher
)

brew install "${apps[@]}"

export DOTFILES_BREW_PREFIX_COREUTILS=`brew --prefix coreutils`
set-config "DOTFILES_BREW_PREFIX_COREUTILS" "$DOTFILES_BREW_PREFIX_COREUTILS" "$DOTFILES_CACHE"
