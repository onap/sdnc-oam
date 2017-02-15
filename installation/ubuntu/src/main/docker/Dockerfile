# Base ubuntu with added packages needed for open ecomp
FROM ubuntu:14.04.5
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)
# Steps needed to run inside ATT
#COPY sources.list /etc/apt
#COPY my_key.pub /tmp
#RUN apt-key add - < /tmp/my_key.pub
# Add tools needed for OpenDaylight
RUN apt-get update && apt-get install -y git openjdk-7-jdk maven2 mysql-client nodejs nodejs-legacy python-pip graphviz npm
