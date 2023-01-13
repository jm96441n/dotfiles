#! /bin/bash
BASE_URL="https://github.com"

if [ -z "$1" ]; then
    echo "Begin with '!' to search"
elif [ "${1::1}" == "!" ]; then
    term=$(echo "${1:1}" | xargs)
    arr=$(gh search repos "$term" --owner=jm96441n --json=fullName | jq "(.[].fullName)")
    arr+=$(gh search repos "$term" --owner=hashicorp --json=fullName | jq "(.[].fullName)")

    arr="${arr//\"/}"
    echo "$arr"
else
    xdg-open "$BASE_URL/$1"
fi
