#!/bin/bash
. ./config.sh
. ./lib.sh

SANDBOX=sandbox_$RANDOM
LOG_FILE=/dev/null

color_print "Using sandbox $SANDBOX"

color_print "Stop services"
service apache2 stop > $LOG_FILE
service mysql stop > $LOG_FILE

color_print "Install apache and mysql"
apt-get update > $LOG_FILE

apt-get -q -y remove apache2 > $LOG_FILE
apt-get -q -y install apache2 > $LOG_FILE

apt-get -q -y remove mysql-server mysql-client > $LOG_FILE
echo "mysql-server mysql-server/root_password password $MYSQL_PASSWORD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD" | debconf-set-selections
apt-get -q -y install mysql-server mysql-client > $LOG_FILE

color_print "deploy app"
cd /tmp
mkdir $SANDBOX
cd $SANDBOX/
git clone https://github.com/FSlyne/NCIRL.git
cd NCIRL/

rm -rf /var/www/*
rm -rf /usr/lib/cgi-bin/*
cp Apache/www/* /var/www/
cp Apache/cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*

color_print "Start services"
service apache2 start
service mysql start

color_print "prepare database"
cat /tmp/scripts/prepare_db.sql | mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD

color_print "Cleanup"
cd /tmp
rm -rf $SANDBOX
