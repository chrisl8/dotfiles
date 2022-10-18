#!/bin/bash
cd || exit
mysqldump --opt --user=ek8wpuser -p --host=localhost ekpowordpress >backup_db.sql
sudo tar --exclude="minecraft-map" --exclude="node_modules" --exclude=".vim" --exclude=".nvm" --exclude=".npm" --exclude=".rvm" --exclude=".heroku" -cvf /tmp/backup.tar /home/chrisl8 /etc /var/www
sudo chown chrisl8:chrisl8 /tmp/backup.tar
rm /tmp/backup.tar.gz
gzip -9 /tmp/backup.tar
echo "From your home system run:"
echo "scp ekpyroticfrood.net:/tmp/backup.tar.gz"
echo "And then put it somewhere safe."
