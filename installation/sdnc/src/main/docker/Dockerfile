# Base ubuntu with added packages needed for open ecomp
FROM openecomp/ubuntu-sdnc-image:${project.version}
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV ODL_HOME /opt/opendaylight/current
ENV SDNC_CONFIG_DIR /opt/openecomp/sdnc/data/properties

# copy the opendaylight tar and expand
COPY distribution-karaf-0.4.2-Beryllium-SR2.tar.gz /tmp
RUN mkdir /opt/opendaylight /opt/openecomp
RUN tar zxvf /tmp/distribution-karaf-0.4.2-Beryllium-SR2.tar.gz --directory /opt/opendaylight
RUN ln -s /opt/opendaylight/distribution-karaf-0.4.2-Beryllium-SR2 /opt/opendaylight/current
COPY idmlight.db.mv.db /opt/opendaylight/current

# copy openecomp
COPY opt /opt
RUN ln -s /opt/openecomp/sdnc /opt/sdnc

# workaround till we get proxy working
COPY mysql.tgz /tmp
RUN tar zxvf /tmp/mysql.tgz --directory /opt/opendaylight/current/system
# ENTRYPOINT exec /opt/opendaylight/current/bin/karaf
EXPOSE 8181
