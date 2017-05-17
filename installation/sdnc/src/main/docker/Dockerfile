# Base ubuntu with added packages needed for open ecomp
FROM openecomp/ubuntu-sdnc-image:${project.version}
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ODL_HOME /opt/opendaylight/current
ENV SDNC_CONFIG_DIR /opt/openecomp/sdnc/data/properties

# copy the opendaylight tar and expand
COPY distribution-karaf-${sdnc.opendaylight.version}.tar.gz /tmp/
RUN mkdir /opt/opendaylight \
&& tar zxvf /tmp/distribution-karaf-${sdnc.opendaylight.version}.tar.gz --directory /opt/opendaylight \
&& rm -rf /tmp/distribution-karaf-${sdnc.opendaylight.version}.tar.gz \
&& ln -s /opt/opendaylight/distribution-karaf-${sdnc.opendaylight.version} /opt/opendaylight/current \
&& mkdir /opt/openecomp

COPY idmlight.db.mv.db /opt/opendaylight/current

# copy openecomp
COPY opt /opt
RUN ln -s /opt/openecomp/sdnc /opt/sdnc

# workaround till we get proxy working
RUN mkdir -p /opt/opendaylight/current/system/mysql/mysql-connector-java/${sdnc.mysql-connector-java.version}
COPY mysql-connector-java-${sdnc.mysql-connector-java.version}.jar /opt/opendaylight/current/system/mysql/mysql-connector-java/${sdnc.mysql-connector-java.version}
# ENTRYPOINT exec /opt/opendaylight/current/bin/karaf
EXPOSE 8181
