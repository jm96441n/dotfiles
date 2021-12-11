#!/bin/bash

if [ -n "$1" ]; then
  open "https://www.google.com"
  exit 0
fi

echo "Input your search term (end it with a '!' to get suggestions)"
