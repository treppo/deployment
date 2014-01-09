#!/bin/bash
set -e # enable checking of all commands by the shell
# set -x # trace execution of all commands

. ./server_config.sh
. ./scripts/lib.sh

CLEAN=0
SANDBOX=/tmp/sandbox_$RANDOM

while test $# -gt 0; do
  case "$1" in
    -i|--initial)
      color_print "Copy ssh key to server"
      ssh-copy-id -p $SERVER_PORT $SERVER_USER@$SERVER_ADDRESS
      shift
      ;;
    -c|--clean)
      CLEAN=1
      shift
      ;;
    *)
      REPO=$1
      break
      ;;
  esac
done

if test -z $REPO; then
  color_print 'You need to provide a git repository'
  exit 1
fi

if test $CLEAN = 1; then
  while test -z $MYSQL_PW; do
    read -s -p "Please enter a password to set for the Mysql database: " MYSQL_PW

    if test -z $MYSQL_PW; then
      echo -e "\nYou need to set a password"
    fi
  done
fi

color_print "Using sandbox $SANDBOX"
ssh -t -i $IDENTITY_FILE -p $SERVER_PORT $SERVER_USER@$SERVER_ADDRESS '
  mkdir '"'$SANDBOX'"'
'

scp -Cr -i $IDENTITY_FILE -P $SERVER_PORT scripts $SERVER_USER@$SERVER_ADDRESS:$SANDBOX
ssh -t -i $IDENTITY_FILE -p $SERVER_PORT $SERVER_USER@$SERVER_ADDRESS '
  export MYSQL_PASSWORD='"'$MYSQL_PW'"'
  export SANDBOX='"'$SANDBOX'"'
  export CLEAN='"'$CLEAN'"'
  export REPO='"'$REPO'"'

  cd '"'$SANDBOX'"'/scripts

  chmod +x *.sh
  sudo -E ./stop_services.sh
  if test $CLEAN = 1; then
    sudo -E ./clean_install.sh
  fi
  sudo -E ./build.sh
  if test $CLEAN = 1; then
    sudo -E ./prepare_db.sh
  fi
  sudo -E ./start_services.sh
  sudo -E ./cleanup.sh
'
