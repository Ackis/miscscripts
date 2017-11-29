#!/bin/bash

WIDTH=49

if [[ -z $1 ]]; then
        echo "No argument supplied."
        exit 1
fi

printf "$1\n$(date +%r)\n$(date +%m-%d-%Y)" | boxes -d simple -p v1 -a c -s $WIDTH
echo ""
