if [[ $(is-macos) == 1 ]]; then
  if [ ! -d ~/.asdf ]; then
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
  fi
  echo "sourcing asdf"
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

env PYTHON_CONFIGURE_OPTS="--enable-framework" asdf install python 3.10.4

asdf global python 3.10.4
# Golang
asdf plugin-add golang

asdf install golang 1.19.5

asdf global golang 1.19.5

# nodejs
asdf plugin-add nodejs

asdf install nodejs 18.5.0

asdf global nodejs 18.5.0

asdf plugin-add rust https://github.com/asdf-community/asdf-rust.git

asdf install rust 1.66.0

asdf global rust 1.66.0
