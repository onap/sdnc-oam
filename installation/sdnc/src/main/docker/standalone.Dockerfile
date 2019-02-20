# Base ubuntu with added packages needed for open ecomp
#FROM onap/ccsdk-odlsli-alpine-image:${ccsdk.docker.version}
FROM onap/ccsdk-odlsli-alpine-image:latest

MAINTAINER SDN-C Team (sdnc@lists.onap.org)

#ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV ODL_HOME /opt/opendaylight
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties
ENV SDNC_STORE_DIR /opt/onap/sdnc/data/stores
ENV SSL_CERTS_DIR /etc/ssl/certs
ENV JAVA_SECURITY_DIR $SSL_CERTS_DIR/java
ENV SDNC_NORTHBOUND_REPO mvn:org.onap.sdnc.northbound/sdnc-northbound-all/${sdnc.northbound.version}/xml/features

# copy onap
COPY opt /opt
RUN test -L /opt/sdnc || ln -s /opt/onap/sdnc /opt/sdnc

# copy SDNC mvn artifacts to ODL repository
COPY system /tmp/system
RUN rsync -a /tmp/system $ODL_HOME && rm -rf /tmp/system

# Add SDNC repositories to boot repositories
RUN cp $ODL_HOME/etc/org.apache.karaf.features.cfg $ODL_HOME/etc/org.apache.karaf.features.cfg.orig
RUN sed -i -e "\|featuresRepositories|s|$|,${SDNC_NORTHBOUND_REPO}|"  $ODL_HOME/etc/org.apache.karaf.features.cfg
RUN sed -i -e "\|featuresBoot[^a-zA-Z]|s|$|,sdnc-northbound-all|"  $ODL_HOME/etc/org.apache.karaf.features.cfg

# imstall ssl and java certificates
COPY truststoreONAPall.jks $JAVA_SECURITY_DIR
COPY truststoreONAPall.jks $SDNC_STORE_DIR

RUN keytool -importkeystore -srckeystore $JAVA_SECURITY_DIR/truststoreONAPall.jks -srcstorepass changeit -destkeystore $JAVA_SECURITY_DIR/cacerts  -deststorepass changeit

ENTRYPOINT /opt/onap/sdnc/bin/startODL.sh
EXPOSE 8181
