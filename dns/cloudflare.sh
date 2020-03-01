#!/bin/bash

# These are the only variables you should need to change to customize your script
INTROMESSAGE="Updating dynamic DNS service CloudFlare."
CONFIG_DIR="/opt/scripts/misc/dns/"
AUTH_EMAIL="cjpasula@gmail.com"

# Display extra logging info
VERBOSE=true
LOG=true

SCRIPT_NAME="$0"
MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f "${MY_PATH}/cloudflare_domains" ]; then
	DOMAINS=(
		"ackis"
)
	else
	readarray -t DOMAINS < "${MY_PATH}/cloudflare_domains"
fi

function print_and_log() {
	# If we weren't passed an argument, fail.
	if [ -z "${1}" ] ; then
		echo "Error: No parameter passed to print_and_log. Function needs at least one string."
		return 1
	fi

	# If verbose is enabled, spout more text.
	if [ "${VERBOSE}" = true ] ; then
		# We can assume we have an argument here
		echo "${1}"
	fi

	# Do we want to log?
	if [ "${LOG}" = true ] ; then
		# Were we passed a second argmument?
		if [ ! -z "${2}" ] ; then
			logger -t CloudflareDNS -p "syslog.${2}" "${1}"
		else
			logger -t CloudflareDNS -p syslog.debug "$1"
		fi
	fi
}

# Check the path where we ran the script for our key
if [ -f "${MY_PATH}/cloudflare_token" ]; then
	print_and_log "Token found at ${MY_PATH}/cloudflare_token." "info"
	AUTH_KEY=$(head -n 1 "${MY_PATH}/cloudflare_token")
# Check the config directory for the key
elif [ -f "${CONFIG_DIR}/cloudflare_token" ]; then
	print_and_log "Token file found at ${CONFIG_DIR}/cloudflare_token." "info"
	AUTH_KEY=$(head -n 1 "${CONFIG_DIR}/cloudflare_token")
# No crypt key file found, therefore assume that we can't run and exit.
else
	print_and_log "No token found." "error"
	exit 1
fi

print_and_log "${INTROMESSAGE}" "info"

# Used code from https://gist.github.com/benkulbertis/fff10759c2391b6618dd
for index in "${!DOMAINS[@]}"; do
	print_and_log "Updating dynamic IP of ${DOMAINS[index]}" "info"

	IP=$(curl -s http://ipv4.icanhazip.com)
	ZONE_IDENTIFIER=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAINS[index]}" -H "X-Auth-Email: ${AUTH_EMAIL}" -H "X-Auth-Key: ${AUTH_KEY}" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
	RECORD_IDENTIFIER=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_IDENTIFIER/dns_records?name=${DOMAINS[index]}" -H "X-Auth-Email: ${AUTH_EMAIL}" -H "X-Auth-Key: ${AUTH_KEY}" -H "Content-Type: application/json"  | grep -Po '(?<="id":")[^"]*')

	# Construct the URL
	URL="\"https://api.cloudflare.com/client/v4/zones/${ZONE_IDENTIFIER}/dns_records/${RECORD_IDENTIFIER}\" -H \"X-Auth-Email: ${AUTH_EMAIL}\" -H \"X-Auth-Key: ${AUTH_KEY}\" -H \"Content-Type: application/json\" --data '{\"type\":\"A\",\"name\":\""${DOMAINS[index]}"\",\"content\":\""${IP}"\",\"ttl\":120,\"proxied\":false}'"

	echo "Sending URL: ${URL}"
	CMD=$(curl -s -X PUT "${URL}")
	STATUS="$?"
	echo "CMD ${CMD}"
	echo "STATUS ${STATUS}"

	case "$CMD" in
		*"\"success\":false"*)
			message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
			echo -e "$message"
			exit 1;;
		*)
			message="IP changed to: $IP"
			echo "$message";;
	esac
done
