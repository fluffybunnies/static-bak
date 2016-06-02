#!/bin/bash
#
# Back up current StaticSite in case we want to use later
#
# NOTE: This is the parent backup script for cron. Don't call the others directly
#
# dont continue if...
# 	currently backing up
# 	currently updating_in_place
# 	healthcheck_current.sh fails
#

. `dirname "$0"`'/../lib/util.sh' ..
log_start



BAK_SOURCE="$APP_PATH/web"



# check reasons to stop
if [ ! -d "$BAK_SOURCE" ]; then
	stop="$BAK_SOURCE is not a directory"
elif [ "`get_proclock back_up`" ]; then
	stop='process currently running'
else
	hc=`./bin/healthcheck_local.sh "$BAK_SOURCE" 2>&1`
	if [ "$hc" != "OK" ]; then
		stop="failed healthcheck: $hc"
	fi
fi
if [ "$stop" ]; then
	log_end "$stop" 'stopping...'
	exit 1
fi
set_proclock back_up



# run
echo "running _back_up_current.sh..."
. ./bin/_back_up_current.sh

# delete local backups X old
if [ "$KEEP_BAKS_FOR_X_DAYS" ]; then
	echo "deleting backups older than $KEEP_BAKS_FOR_X_DAYS days"
	find ./sites -maxdepth 1 -mtime $KEEP_BAKS_FOR_X_DAYS -type f -print0 | xargs -0 rm -v
fi



# finish
unset_proclock back_up
log_end

