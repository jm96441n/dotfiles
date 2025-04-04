if [[ $(is-macos) == 1 ]]; then
  if [ ! -d ~/.asdf ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
  fi
  echo "sourcing asdf"
  . "$HOME/.asdf/asdf.sh"
else
  # asdf for version management
  brew install asdf
fi

# Ruby
asdf plugin-add ruby || true

asdf install ruby 3.2.1

asdf global ruby 3.2.1

# Python
asdf plugin-add python || true

if [[ $(is-macos) == 1 ]]; then
  asdf install python 3.13.2
else
  env PYTHON_CONFIGURE_OPTS="--enable-framework" asdf install python 3.13.2
fi

asdf global python 3.13.2
# Golang
asdf plugin-add golang

asdf install golang 1.23.7

asdf global golang 1.23.7

# nodejs
asdf plugin-add nodejs

asdf install nodejs 18.5.0

asdf global nodejs 18.5.0

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
export PATH="$HOME/.cargo/bin:$PATH"
install_default_cargo_crates() {
  local default_cargo_crates="${HOME}/.default-cargo-crates"

  if [ ! -f "$default_cargo_crates" ]; then return; fi

  while read -r line <"$default_cargo_crates"; do
    name=$(
      echo "$line" |
        sed 's|\(.*\) //.*$|\1|' |
        sed -E 's|^[[:space:]]*//.*||'
    ) # handle full line comments

    if [ -z "$name" ]; then continue; fi
    echo -ne "\nInstalling \033[33m${name}\033[39m cargo crate... "
    cargo install "$name" >/dev/null && rc=$? || rc=$?
    if [[ $rc -eq 0 ]]; then
      echo -e "\033[32mSUCCESS\033[39m"
    else
      echo -e "\033[31mFAIL\033[39m"
    fi
  done
}

install_default_cargo_crates
