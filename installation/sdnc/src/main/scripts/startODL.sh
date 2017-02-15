#!/bin/bash


# Install SDN-C platform components if not already installed and start container

ODL_HOME=${ODL_HOME:-/opt/opendaylight/current}
ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
SDNC_HOME=${SDNC_HOME:-/opt/openecomp/sdnc}
SLEEP_TIME=${SLEEP_TIME:-120}
MYSQL_PASSWD=${MYSQL_PASSWD:-openECOMP1.0}

# 
# Wait for database
#
echo "Waiting for mysql"
until mysql -h dbhost -u root -p${MYSQL_PASSWD} mysql &> /dev/null
do
  printf "."
  sleep 1
done
echo -e "\nmysql ready"

if [ ! -f ${SDNC_HOME}/.installed ]
then
	echo "Installing SDN-C database"
	${SDNC_HOME}/bin/installSdncDb.sh
	echo "Starting OpenDaylight"
	${ODL_HOME}/bin/start
	echo "Waiting ${SLEEP_TIME} seconds for OpenDaylight to initialize"
	sleep ${SLEEP_TIME}
	echo "Installing SDN-C platform features"
	${SDNC_HOME}/bin/installFeatures.sh
	if [ -x ${SDNC_HOME}/svclogic/bin/install.sh ]
	then
		echo "Installing directed graphs"
		${SDNC_HOME}/svclogic/bin/install.sh
	fi


	echo "Restarting OpenDaylight"
	${ODL_HOME}/bin/stop
	echo "Installed at `date`" > ${SDNC_HOME}/.installed
fi

exec ${ODL_HOME}/bin/karaf
