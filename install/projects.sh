#! /usr/bin/bash

urls=(
    AdventOfCode
    TheRustBook
    TheDockerBook
    crackingTheCodingInterview
    leetCode
)

mkdir -p ~/Projects
cd ~/Projects || exit
for url in "${urls[@]}"; do
    if [ ! -d "$HOME/Projects/$url" ]; then
        git clone "https://github.com/jm96441n/$url.git"
    fi
done
cd ~ || exit
