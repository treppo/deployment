#!/bin/bash

function color_print {
  local BLUE='\e[0;32m'
  local END_COLOR='\e[0m'
  echo -e "\n$BLUE$1$END_COLOR"
}
