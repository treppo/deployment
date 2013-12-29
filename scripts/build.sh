#!/bin/bash
. ./lib.sh
. ./mysql_config.sh

LOG_FILE=/dev/null

color_print "Build app"
cd $SANDBOX
git clone https://github.com/FSlyne/NCIRL.git
cd NCIRL/

color_print "Deploy app"
rm -rf /var/www/*
rm -rf /usr/lib/cgi-bin/*
cp Apache/www/* /var/www/
cp Apache/cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*

color_print "Start services"
service apache2 start
service mysql start

color_print "Prepare database"
cat $SANDBOX/scripts/prepare_db.sql | mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD
