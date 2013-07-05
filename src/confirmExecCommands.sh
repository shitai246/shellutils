#!/bin/sh

####
# コマンドをひとつひとつ確認しながら実行するスクリプト
# コマンドを書いたテキストファイルを第1引数に指定する。
# # で始まる行はコメント行として標準出力する。
# 

function confirmExecCommand() {
  command=${*}
  key=""
  while [ "${key}" != "y" -a "${key}" != "e" -a "${key}" != "s" ]
  do
    echo "execute? : ${command}"
    echo -n "(y):yes, (s):skip, (e):exit > "
    read key
  done
  if [ ${key} == "y" ]; then
    ${command}
    return $?
  elif [ ${key} == "e" ]; then
    echo "This scripts is exit."
    return 255
  elif [ ${key} == "s" ]; then
    echo "skip : ${command}"
    return 0
  fi
}

function usage() {
  echo "Usage : $0 commandFile"
}

# 引数のコマンドファイルのチェック
if [ $# -ne 1 ]; then
  usage
  exit 1
fi
commandFile=${1}
if [ $# -ne 1 -o ! -f ${commandFile} ]; then
  usage
  exit 1;
fi

# for文の区切り文字を改行のみにする
IFS_BACKUP=${IFS}
IFS=$'\n'

for command in `cat ${commandFile}`
do
  # 区切り文字を元に戻さないと呼出し側でこけるのでここで戻す。。。
  IFS=${IFS_BACKUP}

  if [ ${command:0:1} == "#" ]; then
    echo "message : ${command:1}"
  else
    confirmExecCommand ${command}
    _RET=${?}
    if [ "${_RET}" != "0" ]; then
      if [ "${_RET}" != "255" ]; then
        echo "Error : ${command} , ReturnCode : ${_RET}"
      fi
      break;
    fi
  fi
done


