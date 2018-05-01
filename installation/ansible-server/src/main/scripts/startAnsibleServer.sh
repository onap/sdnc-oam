#!/bin/bash
exec &> >(tee -a "/var/log/ansible-server.log")

if [ ! -f /tmp/.ansible-server-installed ]
then
	pip install PyMySQL
	pip install cherrypy
	pip install requests

    apt-get -y install software-properties-common
    apt-add-repository -y ppa:ansible/ansible
    apt-get -y install ansible
	date > /tmp/.ansible-server-installed 2>&1
fi

cd /opt/onap/sdnc
exec /usr/bin/python RestServer.py
