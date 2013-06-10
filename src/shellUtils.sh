#!/bin/sh

#### logging
# ロギング処理
# _LOGLEVEL を export しておくと
# そのログレベルに則ってログを出力してくれる。
# _LOGLEVEL が設定されていない場合、
# 自動的に INFO が設定される。
#
## ログレベル一覧
# _LOGLEVEL_DEBUG=0
# _LOGLEVEL_INFO=1
# _LOGLEVEL_WARN=2
# _LOGLEVEL_ERROR=3
# _LOGLEVEL_FATAL=4
# _LOGLEVEL_NONE=5
#
## ロギング関数
# logDebug()
# logInfo()
# logWarn()
# logError()
# logFatal()
#
## ログ形式
# [yyyy/MM/dd HH:mm:ss] [{LOGLEVEL}] {渡された引数全て}
#
_LOGLEVEL_DEBUG=0
_LOGLEVEL_INFO=1
_LOGLEVEL_WARN=2
_LOGLEVEL_ERROR=3
_LOGLEVEL_FATAL=4
_LOGLEVEL_NONE=5
${_LOGLEVEL:=${_LOGLEVEL_INFO}} 2> /dev/null

function _logging() {
  echo "[`date '+%Y/%m/%d %H:%M:%S'`] $*"
}

function logDebug() {
  if [ ${_LOGLEVEL} -le ${_LOGLEVEL_DEBUG} ]; then
    _logging "[DEBUG]" "$*"
  fi
}
function logInfo() {
  if [ ${_LOGLEVEL} -le ${_LOGLEVEL_INFO} ]; then
    _logging "[INFO ]" "$*"
  fi
}
function logWarn() {
  if [ ${_LOGLEVEL} -le ${_LOGLEVEL_WARN} ]; then
    _logging "[WARN ]" "$*"
  fi
}
function logError() {
  if [ ${_LOGLEVEL} -le ${_LOGLEVEL_ERROR} ]; then
    _logging "[ERROR]" "$*"
  fi
}
function logFatal() {
  if [ ${_LOGLEVEL} -le ${_LOGLEVEL_FATAL} ]; then
    _logging "[FATAL]" "$*"
  fi
}

#### Error Handler
 
## errCheck()
# エラーハンドリングを行う。
# 直前に実行したコマンドのリターンコードが0ではないとき、
# プログラムを終了する。
#
## 使い方
# command || errCheck
#
function errCheck() {
  _RET=$?
  if [ "${_RET}" != "0" ]; then
    # error
    logError "return code : ${_RET}"
    exit 1;
  fi
}


#### LockFile Checker
_SCRIPT=`basename $0`
_LOCKFILE="/tmp/.`basename $0 .sh`.lock"

## checkLockFile()
# ロックファイルの有無をチェックする。
# ロックファイルがあればファイルに記載された値のプロセスがあるか確認し、
# プロセスがあればロックが有効とし処理を終了する。
# ロックが有効でないときは、自分のプロセスIDをロックファイルに書き出す。
#
# ロックファイル名は /tmp/.{呼出し元のスクリプト名}.lock とする
#
function checkLockFile() {
  if [ -f ${_LOCKFILE} ]; then
    _PID=`cat ${_LOCKFILE}`
    kill -0 ${_PID} && logWarn "${_SCRIPT} is running." && exit 1;
  fi
  echo $$ > ${_LOCKFILE}
}

## removeLockFile()
# ロックファイルを削除する。
# 
function removeLockFile() {
  rm ${_LOCKFILE}
}

