#!/bin/bash
#
# Download live site into current
#
# Will run regardless of app state. Use parent update.sh to be safe
#


wget \
--mirror \
--page-requisites \
--referer="$SITE" \
--user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:35.0) Gecko/20100101 Firefox/35.0' \
--no-check-certificate \
--remote-encoding=UTF-8 \
--no-dns-cache -4 \
--no-verbose \
--directory-prefix "$APP_PATH/sites/" \
--load-cookies ./cookies \
"$SITE$SEED_PAGE"


# --no-dns-cache  <--  local cache seems to be slowing things down
# -4  <--  skip the IPv6 lookup

