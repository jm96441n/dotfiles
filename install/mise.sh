#! /usr/bin/bash

mise install

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
