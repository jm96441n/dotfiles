if ! is-macos -o ! is-executable brew; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
  . $HOME/.asdf/asdf.sh
  $RUBY_OPTS=$RUBY_CONFIGURE_OPTS 
else
  # asdf for version management
  brew install asdf
  $RUBY_OPTS="--with-openssl-dir=/usr/bin/openssl"
fi


# Ruby
asdf plugin-add ruby

RUBY_CONFIGURE_OPTS=$RUBY_OPTS asdf install ruby 2.7.2

asdf global ruby 2.7.2

# Ruby
asdf plugin-add python

asdf install python 3.8.6
asdf install python 3.9.0

asdf global python 3.9.0

# Ruby
asdf plugin-add golang

asdf install golang 1.15.6

asdf global golang 1.15.6
