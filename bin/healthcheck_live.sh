#!/bin/bash
#
# Sanity check state of live site
#

SITE=$1

if [ "$SITE" == "" ]; then
	echo "missing site argument"
	exit 1
fi

hc=`curl -m5 -sS $SITE`
if [ "`echo \"$hc\" | grep -m1 '<body '`" == "" ]; then
	echo "failed to find snippet on homepage: '<body '"
	exit 1
fi
# replace the above with something that checks to make sure the site is working before making backup, e.g.:
#if [ "`echo \"$hc\" | grep -m1 ' class=\"postteaser'`" == "" ]; then
#	echo "failed to find html snippet on homepage: ' class=\"postteaser'"
#	exit 1
#fi

echo "OK"
