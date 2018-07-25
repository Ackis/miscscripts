#!/bin/bash

echo "This script will create a generic configuration for nginx."
echo "What server name will you be using?"
read server
echo "$server will be used."
echo "What port are we proxying to?"
read port
echo "192.168.0.199:$port will be used."

#filename="/etc/nginx/sites-enabled/$server"
filename="/home/jpasula/nginx_$server"
echo "Created configuration file: $filename"


echo -n upstream $server { >> "$filename"
echo -n 	server					192.168.0.199:$port; >> "$filename"
echo -n 	keepalive				512; >> "$filename"
echo -n } >> "$filename"
echo -n "" >> "$filename"
echo -n server { >> "$filename"
echo -n 	listen					80; >> "$filename"
echo -n 	server_name				"$server"; >> "$filename"
echo -n 	return					301 https://\$server_name\$request_uri; >> "$filename"
echo -n ""  >> "$filename"
echo -n 	access_log				syslog:server=localhost,tag=nginx_access_$server,severity=info combined; >> "$filename"
echo -n 	error_log				syslog:server=localhost,tag=nginx_error_$server; >> "$filename"
echo -n } >> "$filename"
exit
server {
	listen					443 ssl;
	server_name				"$server";

	access_log				syslog:server=localhost,tag=nginx_access_$server,severity=info combined;
	error_log				syslog:server=localhost,tag=nginx_error_$server;

	#ssl_certificate			/etc/letsencrypt/live/$server/fullchain.pem;
	#ssl_certificate_key		/etc/letsencrypt/live/$server/privkey.pem;

	ssl_stapling			on;
	ssl_stapling_verify		on;
	server_tokens			off;

	add_header				Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";
	add_header				X-Frame-Options SAMEORIGIN;
	add_header				X-Content-Type-Options nosniff;
	add_header				X-XSS-Protection "1; mode=block";

	allow					192.168.0.0/24;
	deny					all;

	location = /.well-known/acme-challenge/ {
		return				404;
	}

	location ~* /\.\./ {
		deny				all;
		return				404;
	}

	location ~* "^(?:.+\.(?:htaccess|make|txt|test|markdown|md|engine|inc|info|install|module|profile|po|sh|.*sql|theme|tpl(?:\.php)?|xtmpl)|code-style\.pl|/Entries.*|/Repository|/Root|/Tag|/Template|^#.*#$|\.php(~|\.sw[op]|\.bak|\.orig\.save))$" {
		return				404;
	}

	location = /favicon.ico {
		try_files			/favicon.ico =204;
	}

	location / {
		proxy_pass			http://192.168.0.199:$port/;
		proxy_redirect		http://192.168.0.199:$port/ /;
		proxy_set_header	X-Forwarded-Proto https;
		include				/etc/nginx/conf.d/proxy.conf;
	}
}
