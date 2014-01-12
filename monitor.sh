#!/bin/bash
set -e # enable checking of all commands by the shell
# set -x # trace execution of all commands

. ./server_config.sh

ssh -t -i $IDENTITY_FILE -p $SERVER_PORT $SERVER_USER@$SERVER_ADDRESS '
  mkdir -p /tmp/monitoring
'
scp -Cr -i $IDENTITY_FILE -P $SERVER_PORT scripts $SERVER_USER@$SERVER_ADDRESS:/tmp/monitoring

ssh -t -i $IDENTITY_FILE -p $SERVER_PORT $SERVER_USER@$SERVER_ADDRESS '
  cd /tmp/monitoring/scripts/
  sudo bash monitor.sh
  cd /
  rm -rf /tmp/monitoring
'
