#!/bin/bash

/usr/bin/apt-get install --assume-yes wget curl realpath
. `dirname "$0"`'/lib/util.sh' .


# ssl
chmod 0640 ./install/ssl/*


# nginx conf
/bin/bash ./install/config.nginx.sh


# default site
if [ ! -d ./web ]; then
	ln -s ./sites/default ./web
fi


# update cron
update_log="$__dirname/log/update.log"
crontab_add '#staticBak_update' "0 9 * * * /bin/bash '$__dirname/bin/update.sh' >> '$update_log' 2>&1 #staticBak_update"

# backup cron
backup_log="$__dirname/log/backup.log"
crontab_add '#staticBak_backup' "0 8 * * * /bin/bash '$__dirname/bin/back_up.sh' >> '$backup_log' 2>&1 #staticBak_backup"

# chown assets
crontab_add '#staticBak_chownassets' "* * * * * /bin/bash '$__dirname/bin/chown_assets.sh' #staticBak_chownassets"

# kill hung scripts
kill_long_running_log="$__dirname/log/kill_long_running.log"
crontab_add '#staticBak_kill_long_running' "0 * * * * /bin/bash '$__dirname/bin/kill_long_running.sh' >> '$kill_long_running_log' 2>&1 #staticBak_kill_long_running"


# rotate logs
nginx_access_log='/var/log/nginx/static-bak_access_log.log'
nginx_error_log='/var/log/nginx/static-bak_error_log.log'
logrotate_log="$__dirname/log/logrotate.log"
cron="@daily /bin/bash '$__dirname/bin/logrotate.sh' 30 '$update_log' '$backup_log' '$kill_long_running_log' '$nginx_access_log' '$nginx_error_log' >> '$logrotate_log' 2>&1 #staticBak_rotateLogs"
echo "installing crontab: $cron"
crontab_add '#staticBak_rotateLogs' "$cron"

cron="@weekly /bin/bash '$__dirname/bin/logrotate.sh' 5 '$logrotate_log' >> '$logrotate_log' 2>&1 #staticBak_rotateLogs-logrotate"
echo "installing crontab: $cron"
crontab_add '#staticBak_rotateLogs-logrotate' "$cron"


currentSite=./sites/$SITE
if [ "$1" == "-r" ] && [ ! -d $currentSite ]; then
	echo "s3cmd ls s3://$S3_BUCKET/$S3_KEY_PREFIX/ | grep \"$SITE\" | grep '.tar.gz' | grep -v lastRevert | sort | head -n1 | awk '{print \$N1}' | sed -n \"s/.*$SITE.\([0-9]*\).tar.gz/\1/p\""
	latestBackup=`s3cmd ls s3://$S3_BUCKET/$S3_KEY_PREFIX/ | grep "$SITE" | grep '.tar.gz' | grep -v lastRevert | sort | head -n1 | awk '{print \$N1}' | sed -n "s/.*$SITE.\([0-9]*\).tar.gz/\1/p"`
	echo "latestBackup: $latestBackup"
	if [ "$latestBackup" == "" ]; then
		echo "cant find archived site, running ./bin/update.sh..."
		nohup /bin/bash ./bin/update.sh >> "$update_log" 2>&1 &
	else
		./bin/replace_current_with_backup.sh "$latestBackup"
	fi
fi

# michaels
./bin/chown_assets.sh

# copy default files
if [ -d "$currentSite" ] && [ "$currentSite" != "" ]; then
	cp -Rf ./default_files/* $currentSite/
fi


