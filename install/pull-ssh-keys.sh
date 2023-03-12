#!/usr/bin/bash

set -e

npm install -g @bitwarden/cli
bw login --apikey || true
echo "Logged in!"

echo "getting folder id"
folderID=$(bw get folder "$(hostname)"_ssh_keys | jq "folderId")
export BW_SESSION
BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)
echo "unlocked"

mkdir -p "$HOME/.ssh"

echo "copying github_rsa"
touch "$HOME/.ssh/github_rsa"
bw get item github_rsa | jq -c ".[] | select(.folderId | contains(\"$folderID\")) | .notes" >"$HOME/.ssh/github_rsa"

echo "copying linuxupskillchallenge"
touch "$HOME/.ssh/linuxupskillchallenge.pem"
bw get item linuxupskillchallenge.pem | jq -c ".[] | select(.folderId | contains(\"$folderID\")) | .notes" >"$HOME/.ssh/linuxupskillchallenge.pem"

echo "copying github_rsa.pub"
touch "$HOME/.ssh/github_rsa.pub"
bw get item github_rsa.pub | jq -c ".[] | select(.folderId | contains(\"$folderID\")) | .notes" >"$HOME/.ssh/github_rsa.pub"

echo "copying ssh config"
touch "$HOME/.ssh/config"
bw get item config | jq -c ".[] | select(.folderId | contains(\"$folderID\")) | .notes" >"$HOME/.ssh/config"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_rsa
ssh-add ~/.ssh/hashi

echo "Added SSH key to the ssh-agent"

TOKEN=$(bw get item github.com | jq -r '.fields[0].value')
echo "GITHUB_ACCESS_TOKEN=$TOKEN" >"$DOTFILES_DIR/system/.private_env"
