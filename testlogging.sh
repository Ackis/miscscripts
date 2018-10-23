#!/bin/bash
#                       For more information see rsyslog.conf(5) and /etc/rsyslog.conf
#       http://shallowsky.com/blog/linux/rsyslog-conf-tutorial.html
# Facilities:
#        auth, authpriv, cron, daemon, kern, lpr, mail, news, syslog, user, uucp and local0 through local7
# Priorities:
#       debug, info, notice, warning, err, crit, alert, emerg


# Test various facility and priorities
facnum=0
for i in {auth,authpriv,cron,daemon,kern,lpr,mail,mark,news,syslog,user,uucp,local0,local1,local2,local3,local4,local5,local6,local7}
	do
	facnum=$(($facnum + 1))
	prinum=0
	for k in {debug,info,notice,warning,err,crit,alert,emerg}
		do
			prinum=$(($prinum + 1))
			logger -p $i.$k "Test daemon message, $facnum - $prinum facility $i priority $k"
	done

done

# Test specific syslog filters
logger "UFW"

# Test Logrotate
#/usr/sbin/logrotate -f -v /etc/logrotate.conf
