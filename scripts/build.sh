#!/bin/bash
. ./lib.sh
. ./mysql_config.sh

LOG_FILE=/dev/null

color_print "Build app"
cd $SANDBOX
git clone $REPO app
tar -cJf app.tar.xz app

color_print "Integrate app"
mkdir integration
tar -xJf app.tar.xz -C integration

color_print "Test app"
mkdir test
tar -xJf app.tar.xz -C test

color_print "Deploy app"
mkdir backup
mv /var/www/* backup
mv /usr/lib/cgi-bin/* backup

cd test/
cp app/www/* /var/www/
cp app/cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*

color_print "Start services"
service apache2 start
service mysql start

color_print "Prepare database"
cat $SANDBOX/scripts/prepare_db.sql | mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD
