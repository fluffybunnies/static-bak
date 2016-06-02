
dir=$1
branch=$2

echo "post-gitsync.sh $dir $branch"

cd "$dir"

. ./config.sh

# ssl
chmod 0640 ./install/ssl/*

# copy default files
currentSite=./sites/$SITE
if [ -d $currentSite ]; then
	cp -Rf ./default_files/* $currentSite/
fi
