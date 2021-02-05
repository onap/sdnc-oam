#!/bin/bash

SDNC_DB_USER=${SDNC_DB_USER:-sdnctl}
SDNC_DB_PASSWORD=${SDNC_DB_PASSWORD:-gamma}
SDNC_DB_DATABASE=${SDNC_DB_DATABASE:-sdnctl}
MYSQL_HOST=${MYSQL_HOST:-dbhost}


if [ $# -ne 2 ]
then
  echo "Usage: $0 table foreign-key"
  exit 1
fi

mysql --user=${SDNC_DB_USER} --password=${SDNC_DB_PASSWORD} --host ${MYSQL_HOST} ${SDNC_DB_DATABASE} <<EOF
ALTER TABLE $1
DROP FOREIGN KEY $2;
EOF
