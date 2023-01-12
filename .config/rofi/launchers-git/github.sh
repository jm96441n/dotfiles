#! /bin/bash
GH_USER="jm96441n"
BASE_URL="https://github.com/jm96441n"

if [ -z "$1" ]; then
    echo "Begin with '!' to search"
elif [ "${1::1}" == "!" ]; then
    GH_USER="jm96441n"
    term="dot"
    arr=$(curl -s https://api.github.com/search/repositories\?per_page\=1000\&q\=$term+in:name+user:$GH_USER | jq "(.items[].name)")
    arr="${arr//\"/}"
    echo "$arr"
else
    xdg-open "$BASE_URL/$1"
fi
