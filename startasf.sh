#! /bin/bash

# These are the only variables you should need to change to customize your script
INTROMESSAGE="Starting Archi Steam Farm. Enjoy your badges."
ASF_CONFIG_DIR="/opt/ArchiSteamFarm/config"

# We want to run this as the ASF user
# Why doesn't this work?
#[[ $UID = 999 ]] || exec sudo su -l archisteamfarm -c "$0"

# Display extra logging info
VERBOSE=false
LOG=false
SERVERMODE=false

SCRIPT_NAME="$0"
MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function display_help() {
	echo "This script allows you to start ArchiSteamFarm with ease."
	echo "-v|--verbose:		Verbose mode"
	echo "-h|--help:		Display help"
	echo "-s|--server:		Run in server mode"
	echo "-l|--log:			Enable logging"
}

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
			logger -t ArchiSteamFarm -p "syslog.${2}" "${1}"
		else
			logger -t ArchiSteamFarm -p syslog.info "$1"
		fi
	fi
}

# Check the ASF config directory for the crypt key
if [ -f "${ASF_CONFIG_DIR}/cryptkey" ]; then
	print_and_log "Cryptkey file found at ${ASF_CONFIG_DIR}/cryptkey."
	CRYPTKEY=$(head -n 1 "${ASF_CONFIG_DIR}/cryptkey")
# Check the path where we ran the script for our crypt key
elif [ -f "${MY_PATH}/cryptkey" ]; then
	print_and_log "Cryptkey found at ${MY_PATH}/cryptkey."
	CRYPTKEY=$(head -n 1 "${MY_PATH}/cryptkey")
# No crypt key file found, therefore assume that we can't run the server and exit.
else
	print_and_log "No cryptkey found."
	exit 1
fi

while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		-v | --verbose )
			VERBOSE=true
			shift
			;;
		-h | --help )
			display_help
			exit 2
			;;
		-s | --server )
			SERVERMODE=true
			shift
			;;
		-l | --log )
			LOG=true
			shift
			;;
		* )
			VERBOSE=false
			SERVERMODE=false
			shift
	esac
done

print_and_log "${INTROMESSAGE}"

if [ "${SERVERMODE}" = true ] ; then
	print_and_log "Starting ASF in server mode."
#	/opt/ArchiSteamFarm/ArchiSteamFarm --cryptkey="${CRYPTKEY}" --server
else
	print_and_log "Starting ASF in normal mode."
#	/opt/ArchiSteamFarm/ArchiSteamFarm --cryptkey="${CRYPTKEY}"
fi
