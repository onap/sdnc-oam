# Base ubuntu with added packages needed for open ecomp
FROM openecomp/ubuntu-sdnc-image:${project.version}
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)

# copy openecomp
COPY opt /opt
WORKDIR /opt/openecomp/sdnc/dgbuilder
RUN npm install

#ENTRYPOINT /bin/bash /opt/openecomp/sdnc/dgbuilder/start sdnc1.0
EXPOSE 3100
