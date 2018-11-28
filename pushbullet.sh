#! /bin/bash


# These are the only variables you should need to change to customize your script
INTROMESSAGE="Intromessage: TBD"
CONFIG_DIR="/home/jpasula/.config/pushbullet"
CONFIG_FILE="${CONFIG_DIR}/config"
SCRIPT_NAME="Pushbullet"

# Defaults to display extra logging info
VERBOSE=false
LOG=true

# Internal script variables
SCRIPT_COMMAND="$0"
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
API_KEY=""

function display_help() {
	echo "Help WIP"
	echo "-l|--log:			Enabled logging"
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
# TODO: Fix pathing for logging. Right now it can log as "PATH./script.sh"
		if [ ! -z "${2}" ] ; then
			logger -t "${SCRIPT_PATH}${SCRIPT_COMMAND}" -p "syslog.${2}" "${1}"
		else
			logger -t "${SCRIPT_PATH}${SCRIPT_COMMAND}" -p syslog.debug "$1"
		fi
	fi
}

# Command line parameters:
#	-l|--log:		Logging on
#	-v|--verbose:		Verbose mode
#	-h|--help:		Display help

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
# TODO: Make verbose mode go first
	case $key in
	    	-l | --log )
		    LOG=true
		    print_and_log "${SCRIPT_NAME}: Logging enabled." "debug"
		    shift
		    ;;
		-v | --verbose )
			VERBOSE=true
			print_and_log "${SCRIPT_NAME}: Verbose mode enabled." "debug"
			shift
			;;
		-h | --help )
			display_help
			exit 2
			;;
		* )
			POSITIONAL+=("$1")
			shift
	esac
done
set -- "${POSITIONAL[@]}"

# Check the config directory
if [ -f "${CONFIG_FILE}" ]; then
	print_and_log "${SCRIPT_NAME}: Config file found at ${CONFIG_FILE}." "debug"
	declare -A VARS
	IFS="="
        while read -r lvalue rvalue; do
		VARS[$lvalue]=${rvalue}
	done < "${CONFIG_FILE}"

	if [ -z "${VARS[API_KEY]}" ]; then
		print_and_log "${SCRIPT_NAME}: No api key found in config file." "error"
		exit 1
	else
		API_KEY="${VARS[API_KEY]}"
	fi
# No config file, fail script
else
	print_and_log "${SCRIPT_NAME}: No config file found." "debug"
	exit 1
fi

# TODO: Make these easier to understand when an error occurs.
if [ -z "${1}" ] ; then
	print_and_log "${SCRIPT_NAME}: Please provide a subject for the message to be sent." "error"
	exit 1
else
	SUBJECT="${1}"
fi

if [ -z "${2}" ] ; then
	print_and_log "${SCRIPT_NAME}: Please provice a body of text for the message to be sent." "error"
	exit 1
else
	BODY="${2}"
fi

print_and_log "${INTROMESSAGE}"
RESPONSE=$(curl --silent -u ""${API_KEY}":" -d type="note" -d body=\""${BODY}"\" -d title=\""${SUBJECT}"\" 'https://api.pushbullet.com/v2/pushes' | grep "invalid_access_token")

if [ -z "${RESPONSE}" ] ; then
	print_and_log "${SCRIPT_NAME}: Message sent." "debug"
else
	print_and_log "${SCRIPT_NAME}: Error - message not sent." "error"
fi
