#!/bin/bash

if ! [ -e /usr/bin/wakeonlan ]; then
	echo "Critical error: Wakeonlan not installed."
	exit 1
fi


wakeonlan 78:24:af:47:7f:73
wakeonlan 78:24:af:d9:d6:b5
wakeonlan 78:24:af:47:81:71

