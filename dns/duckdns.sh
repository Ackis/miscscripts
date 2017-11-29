#!/bin/bash

# Current Duck DNS Domains (8/10):
#	ackis
#	anonamouseackis
#	efnetackis
#	freenodeackis
#	ptpackis
#	quackenetackis
#	snoonetackis
#	whatackis

MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f "${MY_PATH}/token" ]; then
        echo "No DuckDNS Token."
	exit 1
        TOKEN=""
else
        TOKEN=$(head -n 1 "${MY_PATH}/token")
	echo "Token found: ${TOKEN}"
fi

LOGLOC="/opt/scripts/dns/log"
LOGFILE="/opt/scripts/dns/log/duckdns.log"

echo "Script output will be logged to $LOGFILE"

#exec > "$LOGFILE" 2>&1
#exec > >(tee -a "$LOGFILE") 2>&1
exec > >(tee "$LOGFILE") 2>&1

/opt/scripts/scriptheader.sh "Duck DNS Update"

logger -p syslog.info "Updating Duck DNS"

echo url="https://www.duckdns.org/update?domains=ackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/ackis.duckdns.org.log" -K -
echo $?
echo url="https://www.duckdns.org/update?domains=anonamouseackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/anonamouseackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=btnackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/btnackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=efnetackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/efnetackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=freenodeackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/freenodeackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=ggnackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/ggnackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=ptpackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/ptpackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=quakenetackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/quakenetackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=snoonetackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/snoonetackis.duckdns.org.log" -K -
echo url="https://www.duckdns.org/update?domains=whatackis&token=$TOKEN&ip=" | curl -k -o "$LOGLOC/whatackis.duckdns.org.log" -K -

