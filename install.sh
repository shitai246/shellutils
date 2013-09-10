#!/bin/sh

THISDIRNAME=`echo $(cd $(dirname $0) && pwd)`
COPYDIRNAME="/usr/local/bin"

for VAL in `ls ${THISDIRNAME}/bin/*`;
do
  chmod 755 ${VAL}
  chown root:root ${VAL}
  ln -is ${VAL} ${COPYDIRNAME}/`basename ${VAL}`
  ls -l ${VAL}
done

