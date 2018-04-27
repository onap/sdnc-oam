#/bin/bash
exec &> /var/log/ansible-server.log

if [ ! -d /tmp/.ansible-server-installed]
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
exec python RestServer.py