#!/bin/bash

function color_print {
  local BLUE='\e[0;32m'
  local END_COLOR='\e[0m'
  echo -e "\n$BLUE$1$END_COLOR"
}

function check_for_change {
  local MD5SUM=$(md5sum $1 | cut -f 1 -d' ')
  local PREVMD5SUM=$(cat /tmp/md5sum)
  local FILECHANGE=0

  if test $MD5SUM != $PREVMD5SUM; then
    FILECHANGE=1
  fi

  echo $MD5SUM > /tmp/md5sum

  echo $FILECHANGE
}
