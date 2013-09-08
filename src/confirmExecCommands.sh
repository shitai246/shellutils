#!/bin/sh

####
# コマンドをひとつひとつ確認しながら実行するスクリプト
# コマンドを書いたテキストファイルを第1引数に指定する。
# # で始まる行はコメント行として標準出力する。
# 

function usage() {
  echo "Usage : ${0} [commandFile]"
  echo ""
  echo "  コマンドをひとつひとつ確認しながら実行するスクリプト"
  echo "  コマンドを書いたテキストファイルを第1引数に指定する。"
  echo "  # で始まる行はコメント行として標準出力する。"
  echo ""
}

### 初期処理
# 引数のコマンドファイルのチェック
if [ $# -ne 1 ]; then
  usage
  exit 1
fi

# コマンドファイル
_commandFile=${1}
if [ $# -ne 1 -o ! -f ${_commandFile} ]; then
  usage
  exit 1;
fi

# 実行ログファイル
_logFile=${_commandFile}.log
_TEE="tee -a ${_logFile}"

# yes に相当するキー配列
_yesKey=("y" "u" "o" "i" "p")

#### confirmExecCommand
# 渡された引数すべてをひとつのコマンドとし、
# 標準入力にて実行確認をとって実行する。
#
function confirmExecCommand() {
  command=${*}
  key=""
  yesKey=`getRandomYesKey`
  while [ "${key}" != "${yesKey}" -a "${key}" != "e" -a "${key}" != "s" ]
  do
    echo "execute? : ${command}"
    echo -n "(${yesKey}):yes, (s):skip, (e):exit > "
    read key
  done

  if [ "${key}" == "${yesKey}" ]; then
    echo "execute : ${command} " | ${_TEE}
    __RESULT=`${command}`
    __RET=${?}
    echo "${__RESULT}" | ${_TEE}
    return ${__RET}
  elif [ "${key}" == "e" ]; then
    echo "exit : ${command}" | ${_TEE}
    return 255
  elif [ "${key}" == "s" ]; then
    echo "skip : ${command}" | ${_TEE}
    return 0
  fi
}

function getRandomYesKey() {
  random=$((RANDOM % ${#_yesKey[*]}))
  echo ${_yesKey[${random}]}
}

### 以下メイン処理

echo "[`date '+%Y/%m/%d %H:%M:%S'`] ${_commandFile} start." | ${_TEE}

# for文の区切り文字を改行のみにする
IFS_BACKUP=${IFS}
IFS=$'\n'

for command in `cat ${_commandFile}`
do
  # 区切り文字を元に戻さないと呼出し側でこけるのでここで戻す。。。
  IFS=${IFS_BACKUP}

  if [ ${command:0:1} == "#" ]; then
    echo "message : ${command:1}" | ${_TEE}
  else
    confirmExecCommand ${command}
    _RET=${?}
    if [ "${_RET}" != "0" ]; then
      if [ "${_RET}" != "255" ]; then
        echo "Error : ${command} , ReturnCode : ${_RET}" | ${_TEE}
      fi
      break;
    fi
  fi
done
echo "[`date '+%Y/%m/%d %H:%M:%S'`] ${_commandFile} end." | ${_TEE}

