#!/bin/bash
. ./lib.sh
. ./mysql_config.sh

LOG_FILE=/dev/null

color_print "Build app"
cd $SANDBOX
git clone $REPO app

color_print "Deploy app"
mkdir backup
mv /var/www/* backup
mv /usr/lib/cgi-bin/* backup

cd app/
cp www/* /var/www/
cp cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*

color_print "Start services"
service apache2 start
service mysql start

color_print "Prepare database"
cat $SANDBOX/scripts/prepare_db.sql | mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD
