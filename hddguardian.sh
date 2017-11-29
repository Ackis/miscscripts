#! /bin/bash

fullfilename=${0##*/}
filename="${fullfilename%.*}"
logfile="/var/log/scripts/$filename.log"
email=pasula.ubuntu@gmail.com
savepath="/home/Shared Docs/SMART/"
runcmd="/usr/sbin/smartctl -a"

echo "Script output will be logged to $logfile"
logger -p syslog.info "Updating SMART attributes.  Output stored in ${savepath}"

exec > "$logfile" 2>&1

/opt/scripts/scriptheader.sh "HDD Guardian Update"

for i in {a,b,c,d,e}
        do
		read MN <<< $(sudo hdparm -I /dev/sd${i} | awk '/Model Number:/ { print $3 }')
		read SN <<< $(sudo hdparm -I /dev/sd${i} | awk '/Serial Number:/ { print $3 }')

		fullpath="${savepath}${MN}_${SN}.txt"

		sudo /usr/sbin/smartctl -a /dev/sd${i} > "${fullpath}"
done

if [[ -f ${logfile} ]]; then
#	echo "Mailing log to ${email}"
#	mail -s "${filename^} Log - $(date +%m-%d-%Y)" ${email} < ${logfile}
fi

