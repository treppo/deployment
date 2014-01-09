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

function app_changed {
  cd $1
  local MD5SUM=$(git rev-parse HEAD)
  cd ..

  local PREVMD5SUM=$(cat /tmp/md5sum 2> /dev/null || 0)
  echo $MD5SUM > /tmp/md5sum

  if test $MD5SUM != $PREVMD5SUM; then
    return 0
  fi

  return 1
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
