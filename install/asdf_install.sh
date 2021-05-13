if [[ $(is-macos) == 1 ]]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
  . $HOME/.asdf/asdf.sh
else
  # asdf for version management
  brew install asdf
fi


# Ruby
asdf plugin-add ruby

asdf install ruby 2.7.2

asdf global ruby 2.7.2

# Python
asdf plugin-add python

asdf install python 3.8.6
asdf install python 3.9.0

asdf global python 3.9.0

# Golang
asdf plugin-add golang

asdf install golang 1.15.6

asdf global golang 1.15.6

# nodejs
asdf plugin-add nodejs

asdf install nodejs 16.1.0

asdf global nodejs 16.1.0
