#!/bin/bash

# Source environment variables
. "$HOME/.dotfiles/system/.private_env"

# Call the Python script and pass arguments
$HOME/.asdf/shims/python "$HOME/.dotfiles/.config/wofi/github.py" "$@"
