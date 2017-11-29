#!/bin/bash

calibre-debug -c "import urllib as u; from calibre.constants import numeric_version; raise SystemExit(int(numeric_version  < (tuple(map(int, u.urlopen('http://calibre-ebook.com/downloads/latest_version').read().split('.'))))))"

UP_TO_DATE=$?

if [ $UP_TO_DATE = 0 ]; then
	echo "Calibre is up-to-date"
else
	sudo service calibre stop
	#calibre --shutdown-running-calibre
	#killall calibre-server
	sudo -v; wget -nv -O- https://github.com/kovidgoyal/calibre/raw/master/setup/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
	sudo chown calibre:mediausers -R /opt/calibre/
	sudo service calibre start
fi
