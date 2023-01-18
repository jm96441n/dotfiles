#! /usr/bin/zsh

urls=(
    consul
    consul-k8s
    envconsul
    consul-dataplane
    consul-api-gateway
)

mkdir -p ~/hashi
for url in "${urls[@]}"; do
    if [ ! -d "$HOME/Projects/$url" ]; then
        git clone "https://github.com/hashicorp/$url.git" "$HOME/hashi/$url"
    fi
done
