#!/bin/bash

SDNC_DB_USER=${SDNC_DB_USER:-sdnctl}
SDNC_DB_PASSWORD=${SDNC_DB_PASSWORD:-gamma}
SDNC_DB_DATABASE=${SDNC_DB_DATABASE:-sdnctl}
MYSQL_HOST=${MYSQL_HOST:-dbhost}

start=$1

if [ $# -eq 1 ]
then
  mysql --user=${SDNC_DB_USER} --password=${SDNC_DB_PASSWORD} --host ${MYSQL_HOST} ${SDNC_DB_DATABASE} <<EOF
INSERT INTO VLAN_ID_POOL (purpose, status, vlan_id) VALUES('VNI', 'AVAILABLE', $start);
EOF
elif [ $# -eq 2 ]
then
   stop=$2
   vlanid=$start
   
   while [ $vlanid -le $stop ]
   do
   mysql --user=${SDNC_DB_USER} --password=${SDNC_DB_PASSWORD}  --host ${MYSQL_HOST} ${SDNC_DB_DATABASE} <<EOF
INSERT INTO VLAN_ID_POOL (purpose, status, vlan_id) VALUES( 'VNI', 'AVAILABLE', $vlanid);
EOF
vlanid=$(( vlanid+1 ))
done
else
  echo "Usage: $0 start [stop]"
  exit 1
fi

