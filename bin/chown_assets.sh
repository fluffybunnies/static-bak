#!/bin/bash
#
# Give php permission to rename assets
#

. `dirname "$0"`'/../lib/util.sh' ..


#if [ -d ./web/compiled ]; then
#	chown -R www-data ./web/compiled
#fi

# allow php to rename any file...
chown -R www-data ./sites


# also fix wget issues
currentSite=./sites/$SITE
echo "currentSite: $currentSite"
if [ -d $currentSite ]; then
	for f in $currentSite/*; do
		if [ ! -f $f ]; then continue; fi
		noExtension=`basename "$f" | grep -v '\.'`
		if [ "$noExtension" ]; then
			tmp="$f.$(date +%s)"
			#echo "mv \"$f\" \"$tmp\" && mkdir -p \"$f\" && mv \"$tmp\" \"$f/index.html\""
			echo "$f > $f/index.html"
			mv "$f" "$tmp" && mkdir -p "$f" && mv "$tmp" "$f/index.html"
		fi
	done
fi
