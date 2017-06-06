# nginx conf

installDir='/var/www/static-bak'
nginxKey='static-bak'
nginxBackend="127.0.0.1:9000"

. $installDir/config.sh
nuddy=`echo "$SITE" | sed -n 's/^www\.//p'`
if [ "$nuddy" ]; then
	nuddyRedir="server { listen 80; server_name $nuddy; return 301 http://www.$nuddy\$request_uri; }"
fi

cat > /etc/nginx/sites-available/$nginxKey <<FILE
#$nuddyRedir
server {
	listen 80;

	server_name $SITE;
	root $installDir/web;
	autoindex off;

	access_log /var/log/nginx/${nginxKey}_access_log.log;
	error_log /var/log/nginx/${nginxKey}_error_log.log;

	gzip on; # use gzip compression
	gzip_min_length 1100;
	gzip_buffers 4 8k; 
	gzip_proxied any; # enable proxy for the fcgi requests
	gzip_types text/plain text/css application/x-javascript text/javascript application/json; 

	# Get default wget index.html load on base domain request
	location = / {
		try_files /index.html =404;
	}
	# Disable http://mydomain.com/index as a duplicate content
	location = /index {
		return 404;
	}

	location / {
		# set expire headers for assets
		if (\$request_uri ~* "\.(ico|css|js|gif|jpe?g|png|svg|swf)\$") {
			add_header x-msg-ws forced-expires;
			expires 30m;
		}
		# wgetted files default to plain text
		# if theres no "." in the last portion of the path, force html
		if (\$request_uri ~* "\/[^\/.]*\$") {
			add_header x-msg-ws forced-content-type;
			add_header content-type "text/html; charset=utf-8";
		}
		include /etc/nginx/fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
		fastcgi_param SCRIPT_NAME /index.php;
		# pass nonexistants to index.php
		if (!-f \$request_filename) {
			fastcgi_pass $nginxBackend;
			break;
		}
	}
}

#server {
#	listen 443;
#	server_name $SITE;
#
#	#server_tokens off;
#	#ssl on;
#	ssl_certificate $installDir/install/ssl/mysite.pem;
#	ssl_certificate_key $installDir/install/ssl/mysite-key.pem;
#	
#	return 404;
#}
FILE
rm /etc/nginx/sites-enabled/default 2> /dev/null
ln -f /etc/nginx/sites-available/$nginxKey /etc/nginx/sites-enabled/$nginxKey

/etc/init.d/nginx reload
