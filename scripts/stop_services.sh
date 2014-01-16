#!/bin/bash
. ./lib.sh

color_print "Stop services"
service apache2 stop >> $LOG_FILE
service mysql stop >> $LOG_FILE
