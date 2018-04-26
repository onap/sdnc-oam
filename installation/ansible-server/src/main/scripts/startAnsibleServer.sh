#/bin/bash

if [ ! -d /tmp/.ansible-server-installed]
then
	pip install PyMySQL
	pip install cherrypy
	pip install requests
	date > /tmp/.ansible-server-installed 2>&1
fi

cd /opt/onap/sdnc
exec python RestServer.py > RestServer.out