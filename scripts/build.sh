#!/bin/bash
. ./lib.sh

LOG_FILE=/dev/null

color_print "Build app"
cd $SANDBOX
git clone $REPO app
tar -cJf built.tar.xz -C app www cgi-bin

FILECHANGE=$(check_for_change built.tar.xz)

if test $FILECHANGE = 1; then
  color_print "Integrate app"
  mkdir integration
  tar -xJf built.tar.xz -C integration
  tar -cJf integration.tar.xz -C integration www cgi-bin

  color_print "Test app"
  mkdir test
  tar -xJf integration.tar.xz -C test
  tar -cJf test.tar.xz -C test www cgi-bin

  color_print "Deploy app"
  mkdir backup
  mkdir backup/www
  mkdir backup/cgi-bin
  mv /var/www/* backup/www
  mv /usr/lib/cgi-bin/* backup/cgi-bin

  mkdir deploy
  tar -xJf test.tar.xz -C deploy

  cd deploy/
  cp www/* /var/www/
  cp cgi-bin/* /usr/lib/cgi-bin/
  chmod a+x /usr/lib/cgi-bin/*
fi

color_print "Start services"
service apache2 start
service mysql start
