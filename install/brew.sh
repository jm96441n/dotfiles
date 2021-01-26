
if ! is-macos -o ! is-executable ruby -o ! is-executable curl -o ! is-executable git; then
  echo "Skipped: Homebrew (missing: ruby, curl and/or git)"
  return
fi

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update
brew upgrade

apps=(
  autojump
  bash-completion2
  # cat clone with syntax highlighting
  bat
  bats
  coreutils
  diff-so-fancy
  fzf
  git
  # https://github.com/tj/git-extras/blob/master/Commands.md
  git-extras
  grep
  geckodriver
  hub
  imagemagick
  jq
  mysql
  neofetch
  neovim
  postgis
  postgresql
  python
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
  zsh-autosuggestions
)

brew install "${apps[@]}"

export DOTFILES_BREW_PREFIX_COREUTILS=`brew --prefix coreutils`
set-config "DOTFILES_BREW_PREFIX_COREUTILS" "$DOTFILES_BREW_PREFIX_COREUTILS" "$DOTFILES_CACHE"
