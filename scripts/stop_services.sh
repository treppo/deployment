#!/bin/bash
. ./lib.sh

LOG_FILE=/dev/null

color_print "Stop services"
service apache2 stop > $LOG_FILE
service mysql stop > $LOG_FILE
