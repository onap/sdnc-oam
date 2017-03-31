# Base ubuntu with added packages needed for open ecomp
FROM ubuntu:16.04
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)
# Set proxy if needed
# RUN echo 'Acquire::http::Proxy "http://your.proxy.com:8080";' > /etc/apt/apt.conf
# Add tools needed for OpenDaylight
RUN apt-get update && apt-get install -y git openjdk-8-jdk maven mysql-client nodejs nodejs-legacy python-pip graphviz npm unzip
