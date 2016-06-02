
export SITE='www.ranktt.com'
export S3_BUCKET='ranktt-baks'
export S3_KEY_PREFIX='static-bak'
export KEEP_BAKS_FOR_X_DAYS=7

if [ -f ./config.local.sh ]; then
	. ./config.local.sh
fi

