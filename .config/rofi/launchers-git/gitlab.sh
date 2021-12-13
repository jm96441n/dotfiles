#!/bin/bash

BASE_URL="https://gitlab.cbinsights.com"

if [ -z "$1" ]; then
    echo "Begin with '!' to search"
elif [ "${1::1}" == "!" ]; then
    term=$(echo "${1:1}" | xargs)
    arr=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" -s "https://gitlab.cbinsights.com/api/v4/projects?per_page=1000&search=$term" | jq ".[].path_with_namespace")
    arr="${arr//\"/}"
    echo "$arr"
else
    xdg-open "$BASE_URL/$1"
fi
