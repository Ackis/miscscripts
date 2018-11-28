#!/bin/bash

# Checks to see if the current user is root.
# If it's not root, the script restarts itself through sudo.
[[ $UID = 0 ]] || exec sudo "$0"

FILE="/var/run/reboot-required.pkgs"

logger -t RebootScript -p syslog.info "Checking to see automatic reboot is needed."

if [ -f "${FILE}" ]; then
	logger -t RebootScript -p syslog.notice "${HOSTNAME} needs an automatic reboot. Performing reboot now."
	/opt/scripts/misc/pushbullet.sh "Automatice Reboot Needed" "${HOSTNAME} needs an automatic reboot. Performing reboot now."
	apt-get autoremove
	apt-get update
	/sbin/shutdown -r now
else
	logger -t RebootScript -p syslog.info "Automatic reboot is not needed."
fi
