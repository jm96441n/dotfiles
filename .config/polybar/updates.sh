#!/bin/bash
if ! updates=$(dnf list --upgrades 2> /dev/null| awk '{print $1}' | wc -l); then
	updates=0
fi

if [ "$updates" -gt 1 ]; then
	echo "  $(($updates - 1))"
else
	echo "  Up to date"
fi
