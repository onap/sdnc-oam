# Base ubuntu with added packages needed for open ecomp
FROM onap/ccsdk-odlsli-image:${ccsdk.distribution.version}

MAINTAINER SDN-C Team (sdnc@lists.onap.org)

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ODL_HOME /opt/opendaylight/current
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties


# Overlay ODL credential database with pre-staged credentials
COPY idmlight.db.mv.db /opt/opendaylight/current

# copy onap
COPY opt /opt
RUN test -L /opt/sdnc || ln -s /opt/onap/sdnc /opt/sdnc


# ENTRYPOINT exec /opt/opendaylight/current/bin/karaf
EXPOSE 8181
