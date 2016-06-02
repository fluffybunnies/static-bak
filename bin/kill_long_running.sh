#!/bin/bash
# ./bin/kill_long_running.sh --dry-run
# force pid: ./bin/kill_long_running.sh --dry-run 29672
#

. `dirname "$0"`'/../lib/util.sh' ..

log_start

updatePid=`ps ax | grep 'static-bak/bin/update.sh' | grep -v grep | head -n1 | awk '{print $1}'`
if [ `is_positive_int "$1"` ]; then updatePid=$1; fi
if [ `is_positive_int "$2"` ]; then updatePid=$2; fi
if [ ! "$updatePid" ]; then
	echo 'update process not detected'
	exit 0
fi

updateRunTime=`ps -p $updatePid -o etime=`
echo "updateRunTime: $updateRunTime"
if [ "`echo $updateRunTime | sed 's/^[0-9]\{2\}.*-//'`" != "`echo $updateRunTime`" ]; then # echo both in case native build strips whitespace
	echo 'process has been running for over 10 days!'
	if [ "$1" != '--dry-run' ] && [ "$2" != '--dry-run' ]; then
		echo "kill $updatePid..."
		kill $updatePid
		echo "unset_proclock update..."
		unset_proclock update
	fi
fi

log_end

