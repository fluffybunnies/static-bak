#!/bin/bash
#
# Replace http://mysite.com/images/tinypigs.jpg with /images/tinypigs.jpg
# Checks local first, then s3
#

. `dirname "$0"`'/../lib/util.sh' ..


currentSite=./sites/$SITE

find "$currentSite" -type f -exec sed -i "s/http:\/\/$SITE\//\//g" {} +
