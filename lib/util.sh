
if [ "`which realpath`" == "" ]; then
	realpath() {
		if [ ! -f "$1" ] && [ ! -d "$1" ]; then
			>&2 echo 'path does not exist'
		else
			dir=$1
			if [ -f "$1" ]; then
				dir=`dirname "$1"`
			fi
			path=`cd "${dir}";pwd`
			if [ -f "$1" ]; then
				path=$path/`basename "$1"`
			fi
			echo $path
		fi
	}
fi

if [ "$1" ]; then
	# configure
	export __dirname=`dirname "$0"`
	export APP_PATH=`realpath "$__dirname/$1"`
	cd "$APP_PATH"
	. ./config.sh
	#echo "APP_PATH: $APP_PATH"
fi

crontab_add(){
  search=$1
  line=$2
  if [ ! "$line" ]; then
    line=$search
  fi

  tmp=`mktemp`
  crontab -l | grep -v "$search" > $tmp
  echo "$line" >> $tmp
  crontab < $tmp 
  rm $tmp
}

crontab_remove(){
  search=$1
  tmp=`mktemp`
  crontab -l | grep -v "$search" > $tmp
  crontab < $tmp
  rm $tmp
}

set_proclock(){
	lockFile=`get_proclock_file "$1"`
	date >> "$lockFile"
}

get_proclock(){
	lockFile=`get_proclock_file "$1"`
	if [ -f "$lockFile" ]; then echo 1; fi
}

unset_proclock(){
	lockFile=`get_proclock_file "$1"`
	rm "$lockFile"
}

get_proclock_file(){
	#key=`echo "$1" | sed -n 's/[^a-zA-Z0-9_-]/_/gp'`
	key=`echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g'`
	echo "/tmp/proclock.$key.lock"
}

log_start(){
	echo '---------- START '`date`' ----------'
	for m in "$@"; do echo "$m"; done
}
log_end(){
	for m in "$@"; do echo "$m"; done
	echo '---------- END '`date`' ----------'
	echo $'\n\n\n'
}

is_positive_int()(
	positiveInt='^[1-9][0-9]*$'
	if [[ "$1" =~ $positiveInt ]]; then
		echo 1
	fi
)


