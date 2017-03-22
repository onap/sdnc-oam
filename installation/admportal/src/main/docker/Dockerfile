# Base ubuntu with added packages needed for open ecomp
FROM openecomp/ubuntu-sdnc-image:${project.version}
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)

# create link for pm2
#RUN ln -s /opt/openecomp/sdnc/admportal/node_modules/pm2/bin/pm2 /usr/bin/pm2

# copy openecomp
COPY opt /opt

#ENTRYPOINT exec /opt/openecomp/sdnc/admportal/shell/startssl.sh
EXPOSE 8843
