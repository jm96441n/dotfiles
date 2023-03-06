#! /bin/bash

echo $(python "$HOME/.dotfiles/.config/rofi/launchers-git/github.py" "$@")

#BASE_URL="https://github.com"
#if [ -z "$1" ]; then
#    echo "Begin with '!' to search"
#elif [ "${1::1}" == "!" ]; then
#    term=$(echo "${1:1}" | xargs)
#    arr=$(gh search repos "$term" --owner=jm96441n --json=fullname | jq "(.[].fullname)")
#    hashiArr=$(gh search repos "$term" --owner=hashicorp --json=fullName | jq "(.[].fullName)")
#    arr+=("${hashiArr}[@]")
#
#    output="${arr//\"/}"
#    echo "$output"
#else
#    xdg-open "$BASE_URL/$1" >/dev/null 2>&1
#fi
