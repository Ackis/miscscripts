# Function to print on screen and log to syslog.
# Syntax: print_and_log(message, app, syslog [debug], verbose [true], log [true])

function print_and_log() {
	# If we weren't passed a message argument, fail.
	if [ -z "${1}" ] ; then
		echo "Error: No parameter passed to print_and_log. Function needs at least one string."
		return 1
	fi

	if [ -z "${2}" ] ; then
		echo "Fail."
		return 1
	fi

	# Deal with the verbose argument
	# We weren't given a verbose argument
	if [ -z "${4}" ] ; then
		echo "${1}"
	# If verbose is enabled, spout more text.
	elif [ "${4}" = true ] ; then
	# We can assume we have an argument for the message
		echo "${1}"
	fi

	# Do we want to log?
	if [ -z "${5}" ] ; then
		# Were we passed a third (syslog facility) argmument?
		if [ ! -z "${3}" ] ; then
			logger -t "${2}" -p "syslog.${3}" "${1}"
		else
			logger -t "${2}" -p syslog.debug "$1"
		fi
	elif [ "${5}" = true ] ; then
		# Were we passed a third (syslog facility) argmument?
		if [ ! -z "${3}" ] ; then
			logger -t "${2}" -p "syslog.${3}" "${1}"
		else
			logger -t "${2}" -p syslog.debug "$1"
		fi

	fi
}
