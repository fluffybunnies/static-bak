#!/bin/bash
# ./bin/logrotate.sh 10 ./out/mylog.log ./out/anotherlog.log

echo 'START '`date`

maxFiles=$1

positiveInt='^[1-9][0-9]*$'
if ! [[ "$maxFiles" =~ $positiveInt ]]; then
	echo "invalid maxFiles arg"
	exit 1
fi

dir=`dirname $0`
if [ ! -f /usr/bin/realpath ]; then
	echo "we lost realpath again. re-installing..."
	apt-get --assume-yes install realpath
	if [ ! -f /usr/bin/realpath ]; then
		echo "realpath failed to install in usual loc. jumping ship."
		exit 1
	fi
fi
dir=`/usr/bin/realpath "$dir"`

dropNginxFileHandler=0

rotate(){
	logFile=$1
	maxFiles=$2
	echo "rotate() $logFile"
	for ((i=$maxFiles;i>=0;i--)); do
		[ $i == 0 ] && suf='' || suf=".$i"
		[ ! -f "$logFile$suf" ] && continue
		if [ $i == $maxFiles ]; then
			# if theres an upload script, fire it off before removing logfile
			uploadLogFileScript="$dir/s3_upload_instance_logfile.sh"
			echo "checking uploadLogFileScript: $uploadLogFileScript"
			if [ -f "$uploadLogFileScript" ]; then
				echo "running uploadLogFileScript: $uploadLogFileScript"
				$uploadLogFileScript "$logFile$suf"
			fi
			echo "rm $logFile$suf"
			rm "$logFile$suf"
			continue
		fi
		echo "$logFile$suf > $logFile."$[$i+1]
		mv "$logFile$suf" "$logFile."$[$i+1]
	done

	# if looks like nginx log, make nginx drop its file handler
	check=`echo "$logFile" | grep nginx`
	if [ "$check" != "" ]; then
		dropNginxFileHandler=1
	fi

}


n=0
for arg in "$@"; do
	n=$[n+1]
	[ $n == 1 ] && continue
	rotate "$arg" $maxFiles
done

#echo "forcing \$dropNginxFileHandler=1"
#dropNginxFileHandler=1

if [ "$dropNginxFileHandler" == "1" ]; then
	echo "identified at least one nginx log file"
	if [ -f /var/run/nginx.pid ]; then
		kill -USR1 `cat /var/run/nginx.pid` && sleep 1 && echo "dropped nginx file handler" || echo "failed to drop nginx file handler :("
	else
		echo "failed to drop nginx file handler: /var/run/nginx.pid is not a file"
	fi
fi


echo 'END '`date`
echo $'\n\n\n'
