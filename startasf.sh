#! /bin/bash

# These are the only variables you should need to change to customize your script
INTROMESSAGE="Starting Archi Steam Farm. Enjoy your badges."
SCRIPT_HOME="/opt/scripts/misc"

# We want to run this as the ASF user
[[ $UID = 999 ]] || exec sudo su -l archisteamfarm -c "$0"

# Display extra logging info
VERBOSE=false
LOG=true
SERVERMODE=false

SCRIPT_NAME="$0"
MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function display_help() {
	echo "Help WIP"
	echo "-v|--verbose:		Verbose mode"
	echo "-h|--help:		Display help"
	echo "-s|--server:		Run in server mode"
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
			logger -t ArchiSteamFarm -p syslog.debug "$1"
		fi
	fi
}

if [ -f "${MY_PATH}/cryptkey" ]; then
	print_and_log "${SCRIPT_NAME}: cryptkey found at ${MY_PATH}/cryptkey." "debug"
	CRYPTKEY=$(head -n 1 "${MY_PATH}/cryptkey")
elif [ -f "${SCRIPT_HOME}/services" ]; then
	print_and_log "${SCRIPT_NAME}: cryptkey file found at ${SCRIPT_HOME}/cryptkey." "debug"
        readarray -t SERVICES < "${SCRIPT_HOME}/cryptkey"
else
	print_and_log "${SCRIPT_NAME}: No cryptkey found." "debug"
	exit 1
fi

# Command line parameters:
#	-v|--verbose:		Verbose mode
#	-h|--help:		Display help
#	-s|--server:		Run in server mode

while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		-v | --verbose )
			VERBOSE=true
			shift
			echo "Verbose mode enabled."
			;;
		-h | --help )
			display_help
			exit 2
			;;
		-s | --server )
			SERVERMODE=true
			shift
			echo "Running in servermode."
			;;
		* )
			VERBOSE=false
			SERVERMODE=false
			shift
	esac
done

print_and_log "${INTROMESSAGE}"

if [ "${SERVERMODE}" = true ] ; then
	/opt/ArchiSteamFarm/ArchiSteamFarm --cryptkey="$CRYPTKEY" --server
else
	/opt/ArchiSteamFarm/ArchiSteamFarm --cryptkey="$CRYPTKEY"
fi
