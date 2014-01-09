#!/bin/bash
. ./mysql_config.sh
. ./lib.sh

LOG_FILE=/dev/null

color_print "Remove and reinstall apache and mysql"
apt-get update > $LOG_FILE

apt-get -q -y remove apache2 > $LOG_FILE
apt-get -q -y install apache2 > $LOG_FILE

apt-get -q -y purge mysql-server mysql-client mysql-common > $LOG_FILE
rm -rf /var/lib/mysql
rm -rf /etc/mysql*
echo "mysql-server mysql-server/root_password password $MYSQL_PASSWORD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD" | debconf-set-selections
apt-get -q -y install mysql-server mysql-client mysql-common > $LOG_FILE

color_print "Install git"
hash git 2>/dev/null || apt-get -q -y install git > $LOG_FILE

color_print "Install tidy"
hash tidy 2>/dev/null || apt-get -q -y install tidy > $LOG_FILE
