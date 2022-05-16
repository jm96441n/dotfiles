if [[ $(is-macos) == 1 ]]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
  . $HOME/.asdf/asdf.sh
else
  # asdf for version management
  brew install asdf
fi


# Ruby
asdf plugin-add ruby

asdf install ruby 3.1.0

asdf global ruby 3.1.0

# Python
asdf plugin-add python

env PYTHON_CONFIGURE_OPTS="--enable-framework" asdf install python 3.9.0

asdf global python 3.9.0
# Golang
asdf plugin-add golang

asdf install golang 1.18.2

asdf global golang 1.18.2

# nodejs
asdf plugin-add nodejs

asdf install nodejs 16.1.0

asdf global nodejs 16.1.0
