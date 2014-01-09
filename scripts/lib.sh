#!/bin/bash
# set -x # trace execution of all commands

function color_print {
  local BLUE='\e[0;32m'
  local END_COLOR='\e[0m'
  echo -e "\n$BLUE$1$END_COLOR"
}

function error_message {
  local RED='\e[0;41m'
  local END_COLOR='\e[0m'
  echo -e "\n$RED$1$END_COLOR"
}

function check_for_change {
  local MD5SUM=$(tar c $1 | md5sum | cut -f 1 -d' ')
  local PREVMD5SUM=$(cat /tmp/md5sum 2> /dev/null || 0)
  local FILECHANGE=0

  if test $MD5SUM != $PREVMD5SUM; then
    FILECHANGE=1
  fi

  echo $MD5SUM > /tmp/md5sum

  echo $FILECHANGE
}

function error_in_html {
  for file in test/www/*.html; do
    tidy -f errors $file > /dev/null

    local NO_ERROR=$(grep '0 errors' errors | wc -l)

    if (($NO_ERROR == 0)); then
      return 0
    fi

    rm errors
  done

  return 1
}
