if ! is-macos -o ! is-executable brew; then
  echo "Skipped: gem"
  return
fi

brew install gpg2

# asdf for version management
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.4.1

asdf plugin-add ruby

asdf install ruby 2.5.0

asdf global ruby 2.5.0
