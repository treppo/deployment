#!/bin/bash
. ./lib.sh

color_print "Rolling back"
mv /tmp/backup/www/* /var/www
mv /tmp/backup/cgi-bin/* /usr/lib/cgi-bin
