#! /bin/bash
GH_USER="jm96441n"
BASE_URL="https://github.com/jm96441n"

if [ -z "$1" ]; then
    arr=$(curl -s "https://api.github.com/users/$GH_USER/repos?per_page=1000" | jq "(.[].name)")
    arr="${arr//\"/}"
    echo "$arr"
else
    xdg-open "$BASE_URL/$1"
fi
