#!/bin/bash

# Source environment variables
source "$HOME/.dotfiles/system/.private_env"

# Launch wofi in drun mode with the custom style
wofi --show drun
