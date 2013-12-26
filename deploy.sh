#!/bin/bash
set -e # enable checking of all commands by the shell
# set -x # trace execution of all commands

. ./scripts/config.sh
. ./scripts/lib.sh


if test $# -gt 0; then
  MYSQL_PW=$1
else
  echo 'Please specify a Mysql password as an argument'
  exit 1
fi

color_print "Copy ssh key to server"
ssh-copy-id -p $SERVER_PORT $SERVER_USER@$SERVER_IP

color_print "Clean install server software"
scp -Cr -P $SERVER_PORT scripts $SERVER_USER@$SERVER_IP:/tmp
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP <<SSH_END
  export MYSQL_PASSWORD=$MYSQL_PW
  cd /tmp/scripts
  /bin/bash clean_install.sh
  cd ..
  rm -rf /tmp/scripts
SSH_END
