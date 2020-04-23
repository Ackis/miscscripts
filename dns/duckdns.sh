#!/bin/bash

# These are the only variables you should need to change to customize your script
INTROMESSAGE="Updating dynamic DNS service DuckDNS."
CONFIG_DIR="/opt/scripts/misc/dns/"

# Display extra logging info
VERBOSE=true
LOG=true

SCRIPT_NAME="$0"
MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f "${MY_PATH}/duckdns_domains" ]; then
	DOMAINS=(
		"ackis"
)
	else
	readarray -t DOMAINS < "${MY_PATH}/duckdns_domains"
fi

source /opt/scripts/misc/common.sh

# Check the path where we ran the script for our key
if [ -f "${MY_PATH}/duckdns_token" ]; then
	print_and_log "Token found at ${MY_PATH}/duckdns_token." "DuckDNS" "info"
	TOKEN=$(head -n 1 "${MY_PATH}/duckdns_token")
# Check the config directory for the key
elif [ -f "${CONFIG_DIR}/duckdns_token" ]; then
	print_and_log "Token file found at ${CONFIG_DIR}/duckdns_token." "DuckDNS" "info"
	TOKEN=$(head -n 1 "${CONFIG_DIR}/duckdns_token")
# No crypt key file found, therefore assume that we can't run and exit.
else
	print_and_log "No token found." "DuckDNS" "error"
	exit 1
fi

print_and_log "${INTROMESSAGE}" "DuckDNS" "info"

for index in "${!DOMAINS[@]}"; do
	print_and_log "Updating dynamic IP of ${DOMAINS[index]}.duckdns.org" "DuckDNS" "info"

	# Construct the URL
	# Leaving the IP4 blank, the service detects our IP.
	# Get the IP6 address of the system
	IPV6=$(ip -6 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done)

	if [ -z "${IPV6}" ] ; then
		echo "Error: No IP6 address found."
		URL="https://www.duckdns.org/update?domains=${DOMAINS[index]}&token=${TOKEN}&verbose=${VERBOSE}"
	else
		URL="https://www.duckdns.org/update?domains=${DOMAINS[index]}&token=${TOKEN}&ip=&ipv6=${IPV6}&verbose=${VERBOSE}"
	fi

	echo "Sending URL: ${URL}"
	CMD=$(curl -s -S -f "${URL}")
	STATUS="$?"
	echo "CMD ${CMD}"
	echo "STATUS ${STATUS}"
	if [ "${STATUS}" = 0 ] ; then
		print_and_log "Successfully updated dynamic IP of ${DOMAINS[index]}.duckdns.org" "DuckDNS" "info"
	else
		print_and_log "Failed opdating dynamic IP of ${DOMAINS[index]}.duckdns.org" "DuckDNS" "error"
	fi
done
