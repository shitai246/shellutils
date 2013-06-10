#! /bin/sh

. ../src/shellutils.sh

testErrCheck() {
  cd ./notExistDir 2> /dev/null
  RET=`errCheck`
  assertEquals $? 1
}

testLogLevel() {
  assertEquals ${_LOGLEVEL} 1
}

testLogDebug() {
  export _LOGLEVEL=1
  assertNull "`logDebug aa`"
  export _LOGLEVEL=0
  assertNotNull "`logDebug aa`"
}

testLogInfo() {
  export _LOGLEVEL=2
  assertNull "`logInfo aa`"
  export _LOGLEVEL=1
  assertNotNull "`logInfo aa`"
}

testLogWarn() {
  export _LOGLEVEL=3
  assertNull "`logWarn aa`"
  export _LOGLEVEL=2
  assertNotNull "`logWarn aa`"
}

testLogError() {
  export _LOGLEVEL=4
  assertNull "`logError aa`"
  export _LOGLEVEL=3
  assertNotNull "`logError aa`"
}

testLogFatal() {
  export _LOGLEVEL=5
  assertNull "`logFatal aa`"
  export _LOGLEVEL=4
  assertNotNull "`logFatal aa`"
}

testCheckLockFile() {
  checkLockFile
  PID=`cat /tmp/.shellUtilsTest.lock`
  assertEquals ${PID} $$
  RET=`checkLockFile`
  assertEquals $? 1
  removeLockFile
  test -f /tmp/.shellUtilsTest.lock 2> /dev/null
  assertEquals $? 1
}

. ./shunit2-2.1.6/src/shunit2
