#!/bin/bash
exec &> >(tee -a "/var/log/ansible-server.log")

cd /opt/ansible-server
exec /usr/local/bin/python3 RestServer.py

