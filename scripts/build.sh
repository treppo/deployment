#!/bin/bash
. ./lib.sh

FILECHANGE=0
ERRORCOUNT=0

cd $SANDBOX
git clone $REPO app

color_print "Build static content"
tar -cf build.tar -C app www

if ! app_changed app; then
  error_message 'App did not change since last deploy. Aborting.'
  exit 0
fi

color_print "Integrate dynamic content"
mkdir integration
tar -xf build.tar -C integration

mv app/cgi-bin integration

tar -cf integration.tar -C integration www cgi-bin


color_print "Test app"
mkdir test
tar -xf integration.tar -C test

if error_in_html; then
  error_message "The HTML is not valid, deployment aborted"
  exit 1
fi

tar -cf test.tar -C test www cgi-bin


color_print "Deploy app"
mkdir -p /tmp/backup/www
mkdir -p /tmp/backup/cgi-bin
rm -rf /tmp/backup/www/*
rm -rf /tmp/backup/cgi-bin/*
mv /var/www/* /tmp/backup/www
mv /usr/lib/cgi-bin/* /tmp/backup/cgi-bin

mkdir deploy
tar -xf test.tar -C deploy

cd deploy/
cp www/* /var/www/
cp cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*
