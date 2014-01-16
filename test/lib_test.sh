#! /bin/sh
. ./scripts/lib.sh

testWriteToLog ()
{
  LOG_FILE=/tmp/test.log

  color_print "Test message" > /dev/null

  assertTrue "grep 'Test message' /tmp/test.log"

  rm /tmp/test.log
}
