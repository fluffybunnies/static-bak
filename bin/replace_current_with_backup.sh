#!/bin/bash
#
# Replace current StaticSite with backup
# Checks local first, then s3
#

. `dirname "$0"`'/../lib/util.sh' ..


KEY=$1
if [ "$KEY" == "" ]; then
	echo "missing key argument"
	exit 1
fi


sourceKey=$SITE.$KEY
sourceFn=$sourceKey.tar.gz
sourcePath=$APP_PATH/sites/$sourceFn
echo "sourcePath: $sourcePath"
if [ ! -f "$sourcePath" ]; then
	echo "local backup not found, checking s3..."
	echo "s3cmd get s3://$S3_BUCKET/$S3_KEY_PREFIX/$sourceFn \"$sourcePath\""
	s3cmd get s3://$S3_BUCKET/$S3_KEY_PREFIX/$sourceFn "$sourcePath"
	check=`cat "$sourcePath" | head -n1`
	if [ "$check" == "" ]; then
		rm "$sourcePath"
	fi
fi
if [ ! -f "$sourcePath" ]; then
	echo "cant find backup $sourceKey"
	exit 1
fi

tmp=`mktemp -u -t backup.XXXXXX`
mkdir $tmp
tar -zxf "$sourcePath" -C $tmp
currentSite=./sites/$SITE
if [ -d $currentSite ]; then
	mv -f $currentSite ./sites/lastRevert
fi
mv -f $tmp $currentSite

# copy default files
cp -Rf ./default_files/* $currentSite/
# symlink web dir
rm ./web # ln -f is not overwriting
ln -sf $currentSite ./web

# tar up old site in case we want to revert the revert
if [ -d ./sites/lastRevert ]; then
	BAK_SOURCE=./sites/lastRevert
	BAK_KEY='lastRevert'
	. ./bin/_back_up_current.sh
	rm -fr $BAK_SOURCE
fi

