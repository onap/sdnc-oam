# Base ubuntu with added packages needed for open ecomp
FROM openecomp/ubuntu-sdnc-image:${project.version}
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)

# copy openecomp
COPY opt /opt
WORKDIR /opt/openecomp/sdnc/dgbuilder
# Set the proxy if needed
# RUN npm config set proxy http://your.proxy.com:8080
#RUN npm install

#ENTRYPOINT /bin/bash /opt/openecomp/sdnc/dgbuilder/start sdnc1.0
EXPOSE 3100
