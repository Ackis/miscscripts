#!/bin/bash

MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f "${MY_PATH}/domains" ]; then
	DOMAINS=(
		"ackis"
)
	else
	readarray -t DOMAINS < "${MY_PATH}/domains"
fi


if [ ! -f "${MY_PATH}/token" ]; then
        echo "No DuckDNS Token."
	exit 1
        TOKEN=""
else
        TOKEN=$(head -n 1 "${MY_PATH}/token")
	echo "Token found: ${TOKEN}"
fi

LOGLOC="/var/log/dns"
LOGFILE="${LOGLOC}/duckdns.log"

echo "Script output will be logged to $LOGFILE"

exec > >(tee "$LOGFILE") 2>&1

/opt/scripts/misc/scriptheader.sh "Duck DNS Update"

logger -p syslog.info "Updating Duck DNS"

for index in "${!DOMAINS[@]}"; do
	echo "${DOMAINS[index]}"
	echo url="https://www.duckdns.org/update?domains=${DOMAINS[index]}&token=$TOKEN&ip=" | curl -k -o "${LOGLOC}/${DOMAINS[index]}.duckdns.org.log" -K -
done
