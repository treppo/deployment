#!/bin/bash
. ./lib.sh
. ./mysql_config.sh

color_print "Prepare database"
cat $SANDBOX/scripts/prepare_db.sql | mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD
