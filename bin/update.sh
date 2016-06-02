#!/bin/bash
#
# Update current StaticSite by pulling live site
#
# NOTE: This is the parent sync script for cron. Don't call the others directly
#
# dont continue if...
# 	currently updating
# 	currently back_up.shing? (consider put in queue)
# 	healthcheck_livesite.sh fails
#

. `dirname "$0"`'/../lib/util.sh' ..
log_start



# check reasons to stop
if [ "$1" != "-f" ]; then
	if [ "`get_proclock update`" ]; then
		stop='process currently running'
	elif [ "$SKIP_HC" != "1" ]; then
		hc=`./bin/healthcheck_live.sh "$SITE" 2>&1`
		if [ "$hc" != "OK" ]; then
			stop="failed healthcheck: $hc"
		fi
	fi
fi
if [ "$stop" ]; then
	log_end "$stop" 'stopping...'
	exit 1
fi
set_proclock update



# ensure target dir exists
currentSite=./sites/$SITE
if [ ! -d $currentSite ]; then
	mkdir $currentSite
fi
# copy default files
cp -Rf ./default_files/* $currentSite/
# symlink web dir
rm ./web # ln -f is not overwriting
ln -sf $currentSite ./web
# run
echo "running _update_in_place.sh..."
. ./bin/_update_in_place.sh



# finish
unset_proclock update
log_end


