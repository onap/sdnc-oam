# Base ubuntu with added packages needed for open ecomp
FROM onap/ccsdk-odlsli-image:${ccsdk.distribution.version}

MAINTAINER SDN-C Team (sdnc@lists.onap.org)

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ODL_HOME /opt/opendaylight/current
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties
ENV SDNC_NORTHBOUND_REPO mvn:org.onap.sdnc.northbound/sdnc-northbound-all/${sdnc.northbound.version}/xml/features

# Overlay ODL credential database with pre-staged credentials
COPY idmlight.db.mv.db /opt/opendaylight/current/data

# copy onap
COPY opt /opt
RUN test -L /opt/sdnc || ln -s /opt/onap/sdnc /opt/sdnc

# copy SDNC mvn artifacts to ODL repository
COPY system /tmp/system
RUN rsync -a /tmp/system $ODL_HOME && rm -rf /tmp/system

# Add SDNC repositories to boot repositories
RUN cp $ODL_HOME/etc/org.apache.karaf.features.cfg $ODL_HOME/etc/org.apache.karaf.features.cfg.orig
RUN cat $ODL_HOME/etc/org.apache.karaf.features.cfg.orig | sed -e "\|featuresRepositories|s|$|,${SDNC_NORTHBOUND_REPO}|" > $ODL_HOME/etc/org.apache.karaf.features.cfg.1
RUN cat $ODL_HOME/etc/org.apache.karaf.features.cfg.1 | sed -e "\|featuresBoot=config|s|$|,sdnc-northbound-all|" > $ODL_HOME/etc/org.apache.karaf.features.cfg

# install AAF configs
COPY aaa-app-config.xml $ODL_HOME/etc/opendaylight/datastore/initial/config/
COPY aaf-shiro-aafrealm-osgi-bundle.jar $ODL_HOME/deploy/
RUN echo "cadi_prop_files=$SDNC_CONFIG_DIR/org.onap.sdnc.cred.props" >> $ODL_HOME/system.properties

# ENTRYPOINT exec /opt/opendaylight/current/bin/karaf
EXPOSE 8181
