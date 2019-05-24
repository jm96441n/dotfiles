if ! is-macos -o ! is-executable brew; then
  echo "Skipped: gem"
  return
fi

brew install gpg2

# asdf for version management
brew install asdf

asdf plugin-add ruby

asdf install ruby 2.5.0
asdf install ruby 2.5.3

asdf global ruby 2.5.3
