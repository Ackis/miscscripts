#! /bin/bash

# These are the only variables you should need to change to customize your script
INTROMESSAGE="TBD"
CONFIG_DIR="/home/jpasula/.config/pushbullet"
CONFIG_FILE="${CONFIG_DIR}/config"
SCRIPT_NAME="Pushbullet"

# Defaults to display extra logging info
VERBOSE=false
LOG=true

# Internal script variables
SCRIPT_NAME="$0"
MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function display_help() {
	echo "Help WIP"
	echo "-v|--verbose:		Verbose mode"
	echo "-h|--help:		Display help"
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
			logger -t "${SCRIPT_NAME}" -p "syslog.${2}" "${1}"
		else
			logger -t "${SCRIPT_NAME}" -p syslog.debug "$1"
		fi
	fi
}

echo "${CONFIG_FILE}"

# Check the config directory
if [ -f "${CONFIG_FILE}" ]; then
	print_and_log "${SCRIPT_NAME}: Config file found at ${CONFIG_FILE}." "debug"
	API_KEY=$(head -n 1 "${CONFIG_FILE}")
echo "${API_KEY}"
# No crypt key file found, therefore assume that we can't run the server and exit.
else
	print_and_log "${SCRIPT_NAME}: No config file found." "debug"
	exit 1
fi

echo "3"

# Command line parameters:
#	-v|--verbose:		Verbose mode
#	-h|--help:		Display help

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
		* )
			VERBOSE=false
			shift
	esac
done

print_and_log "${INTROMESSAGE}"
