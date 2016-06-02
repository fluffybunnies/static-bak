#!/bin/bash
#
# tar up current StaticSite
#
# Will run regardless of app state. Use parent back_up.sh to be safe
#

startpwd=`pwd`

if [ "$BAK_KEY" == "" ]; then
	#BAK_KEY=$(date +%Y%m%d_%H%M%S)
	BAK_KEY=$(date +%Y%m%d)
fi

echo "BAK_SOURCE: $BAK_SOURCE"
cd "$BAK_SOURCE"
targetFn=$SITE.$BAK_KEY.tar.gz
echo "targetFn: $targetFn"
target=$APP_PATH/sites/$targetFn
echo "target: $target"
includeFile=`mktemp -t back_up.XXXXXX`
echo "includeFile: $includeFile"
find . -type f > $includeFile
tar -T $includeFile -zcf "$target"
rm $includeFile
if [ -f "$target" ]; then
	echo "s3cmd put \"$target\" s3://$S3_BUCKET/$S3_KEY_PREFIX/$targetFn"
	s3cmd put "$target" s3://$S3_BUCKET/$S3_KEY_PREFIX/$targetFn
else
	echo "failed to create $target"
fi

cd "$startpwd"
