#!/bin/bash

SDNC_DB_USER=${SDNC_DB_USER:-sdnctl}
SDNC_DB_PASSWORD=${SDNC_DB_PASSWORD:-gamma}
SDNC_DB_DATABASE=${SDNC_DB_DATABASE:-sdnctl}
MYSQL_HOST=${MYSQL_HOST:-dbhost}

universe=$1
subnet=$2
start=$3

if [ $# -eq 3 ]
then
  mysql --user=${SDNC_DB_USER} --password=${SDNC_DB_PASSWORD} --host=${MYSQL_HOST} ${SDNC_DB_DATABASE} <<EOF
INSERT INTO IPV4_ADDRESS_POOL VALUES('', '$universe', 'AVAILABLE', '${subnet}.${start}');
EOF
elif [ $# -eq 4 ]
then
   stop=$4
   ip=$start

   while [ $ip -le $stop ]
   do
   mysql --user=${SDNC_DB_USER} --password=${SDNC_DB_PASSWORD} --host=${MYSQL_HOST} ${SDNC_DB_DATABASE} <<EOF
INSERT INTO IPV4_ADDRESS_POOL VALUES('', '$universe', 'AVAILABLE','${subnet}.${ip}');
EOF
ip=$(( ip+1 ))
done
else
  echo "Usage: $0 universe subnet start [stop]"
  exit 1
fi

