#!/bin/bash
#
# Sanity check state of current StaticSite
# 	HP should have opening+closing html tags
# 	HP should have some html elements indicative of a successful load
# 	Primary links on HP should have corresponding content
# 	Global css + js + images (e.g. logo) should exist and have size
# 	etc
#


SITE=$1

if [ "$SITE" == "" ]; then
	echo "missing site argument"
	exit 1
fi


hc=`cat "$SITE/index.html"`
if [ "`echo \"$hc\" | grep -m1 ' class=\"postteaser'`" == "" ]; then
	echo "failed to find html snippet on homepage: ' class=\"postteaser'"
	exit 1
fi


echo "OK"
