if ! is-macos -o ! is-executable brew; then
  echo "Skipped: gem"
  return
fi
# asdf for version management
brew install asdf

# Ruby
asdf plugin-add ruby

asdf install ruby 2.5.0
asdf install ruby 2.5.3

asdf global ruby 2.5.3

# Ruby
asdf plugin-add python

asdf install python 3.8.6
asdf install python 3.9.0

asdf global python 3.9.0

# Ruby
asdf plugin-add golang

asdf install golang 1.15.6

asdf global golang 1.15.6
