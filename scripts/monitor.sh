#!/bin/bash
# Level 0 functions

. ./mysql_config.sh
. ./monitor.conf
. ./lib.sh

function isRunning {
  local COUNT=$(ps -ef | grep "$1" | grep -cv "grep")

  if (($COUNT > 0)); then
    return 0
  fi

  return 1
}

function isTcpListening {
  local COUNT=$(netstat -tupln | grep tcp | grep -c "$1")

  if (($COUNT > 0)); then
    return 0
  fi

  return 1
}

function isRemoteTcpOpen {
  $(: < /dev/tcp/$1/$2)
}

function isIpAlive {
  ping -c 1 -t 100 "$1" 2> /dev/null
}



# Level 1 functions

function isApacheRunning {
  isRunning apache2
  return $?
}

function isApacheListening {
  isTcpListening 80
  return $?
}

function isMysqlListening {
  isTcpListening $MYSQL_PORT
  return $?
}

function isMysqlRunning {
  isRunning mysqld
  return $?
}

function isMysqlRemoteUp {
  isRemoteTcpOpen $MYSQL_IP $MYSQL_PORT
  return $?
}

function isMysqlIpReachable {
  isIpAlive $MYSQL_IP
  return $?
}

function isCpuLoadAboveLimit {
  local UPTIME=$(uptime | cut  -d ':' -f 5)
  local TIMES=(${UPTIME//,  / })
  local LIMIT=$1

  for i in "${TIMES[@]}"; do
    local ABOVE=$(echo $i'>'$LIMIT | bc)

    if test $ABOVE -eq 1; then
      return 1
    fi
  done

  return 0
}



# Level 2 functions

function isSystemSane {
  local SYSTEM_IS_SANE=0
  local MESSAGE=""

  if ! isApacheRunning; then
    SYSTEM_IS_SANE=1
    MESSAGE+="The Apache process is not running.\n"
  fi

  if ! isApacheListening; then
    SYSTEM_IS_SANE=1
    MESSAGE+="Apache is not listening on port 80.\n"
  fi

  if ! isMysqlListening; then
    SYSTEM_IS_SANE=1
    MESSAGE+="The Mysql database is not listening on port $MYSQL_PORT\n"
  fi

  if ! isMysqlRunning; then
    SYSTEM_IS_SANE=1
    MESSAGE+="The Mysql process is not running.\n"
  fi

  if ! isMysqlRemoteUp; then
    SYSTEM_IS_SANE=1
    MESSAGE+="Mysql remote port $MYSQL_PORT is not open.\n"
  fi

  if ! isMysqlIpReachable; then
    SYSTEM_IS_SANE=1
    MESSAGE+="The Mysql servers IP address is not reachable.\n"
  fi

  if ! isCpuLoadAboveLimit $CPU_LIMIT; then
    SYSTEM_IS_SANE=1
    MESSAGE+="The CPU limit is above the limit ($CPU_LIMIT)\n"
  fi

  if test $SYSTEM_IS_SANE == 1; then
    error_message 'There are problems with the server:'

    ssmtp -ap"$EMAIL_PW" christian@treppo.org <<EOF
Subject: Alert

There are problems with the server:
$(echo -e $MESSAGE)
EOF
  else
    color_print 'All systems are OK'
  fi

  return $SYSTEM_IS_SANE
}


# execute monitoring
isSystemSane
