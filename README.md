# static-bak
Make static copy of your website in case of backend outage
- Fetches static pages from production once a day
- Saves 7 days of sites locally for historical backup
	- Also ship to s3
- Upon installation, it will try to download the latest backup from s3
	- If that fails, it will immediately start fetching from prod



### Install
[See google doc here](https://docs.google.com/document/d/1mUiHmJy5nLpjVLFMEbawunCTc_lV17e0_f9sCDcTGYI)


<!--
### Install
Reqs: nginx, php, s3, s3 creds, git access
```bash
git clone git@github.com:fluffybunnies/static-bak.git /var/www/static-bak
/var/www/static-bak/install.sh
```



### Install with [Sire](https://github.com/fluffybunnies/sire)
Reqs: none (software + credentials installed for you)
```
# 1. Edit ./sire/_deploy/config.chef.sh
# 2. Deploy sire to remote server:
./sire/index.sh _deploy
# 3. Install static-bak on remote server:
./sire/signal.sh static-bak
```
-->



### Revert to backup
In case something goes wrong with current set of files
```bash
/var/www/static-bak/bin/replace_current_with_backup.sh 20150630
```
If you want to revert the revert:
```bash
/var/www/static-bak/bin/replace_current_with_backup.sh lastRevert
```



### To Do
- Find and kill Content-Type: application/octet-stream
	- Refreshing an article prompts a download in FF, hard refresh avoids this. Maybe nginx's default content-type is app/octet and that's what's sent for 304s.
	- Also in FF there are 2 requests showing in net panel when page has been cached by browser
- Fix memory usage issues when wget runs for 3+ hours
- Test in different browsers (e.g. content type stuffs)
- Solve wget file-created-before-directory issue
	- e.g.: Cannot write to ‘/var/www/static-bak/current/www.mysite.com/beauty/shop/makeup/troi-ollivierre-zen-lipstick-toni’ (Not a directory)
	- temp solution in bin/chown_assets.sh
- Lock down file overwrite rules
- Finish readme
	- replace-with-backup script instructions
- Misc stuffs
	- Pagination on categories/search/etc
	- Performance: review index.php rules and rename files so nginx can handle them on subsequent requests
- Make faster by switching to node
	- Just need to modify my scraper to save data instead of discarding: [link removed] <!--[domain-forwarder scrape_site.js](https://github.com/fluffybunnies/domain-forwarder/blob/master/bin/scrape_site.js)-->

