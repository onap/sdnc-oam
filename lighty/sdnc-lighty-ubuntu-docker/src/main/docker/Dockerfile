# Base ubuntu with added packages needed for open ecomp
FROM onap/ccsdk-ubuntu-image:${ccsdk.docker.version}
MAINTAINER SDN-C Team (sdnc@lists.onap.org)

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ODL_HOME /opt/opendaylight/current
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties
ENV SDNC_STORE_DIR /opt/onap/sdnc/data/stores
ENV SSL_CERTS_DIR /etc/ssl/certs
ENV JAVA_SECURITY_DIR $SSL_CERTS_DIR/java
ENV SDNC_NORTHBOUND_REPO mvn:org.onap.sdnc.northbound/sdnc-northbound-all/${sdnc.northbound.version}/xml/features
ENV SDNR_NORTHBOUND_REPO mvn:org.onap.ccsdk.features.sdnr.northbound/sdnr-northbound-all/${ccsdk.features.version}/xml/features
ENV SDNR_WT_REPO mvn:org.onap.ccsdk.features.sdnr.wt/sdnr-wt-feature-aggregator/${ccsdk.features.version}/xml/features
ENV SDNC_KEYSTORE ${sdnc.keystore}
ENV SDNC_KEYPASS ${sdnc.keypass}
ENV SDNC_SECUREPORT ${sdnc.secureport}

USER root

# copy application
COPY ${lighty.app.zip} /tmp/lighty/
RUN mkdir -p /opt/lighty \
    && unzip /tmp/lighty/${lighty.app.zip} -d /opt/lighty \
    && rm -rf /tmp/lighty

# workaround till we get proxy working
RUN mkdir -p /opt/opendaylight/system/org/mariadb/jdbc/mariadb-java-client/${ccsdk.mariadb-connector-java.version}
COPY mariadb-java-client-${ccsdk.mariadb-connector-java.version}.jar /opt/opendaylight/system/org/mariadb/jdbc/mariadb-java-client/${ccsdk.mariadb-connector-java.version}

COPY opt /opt
RUN test -L /opt/sdnc || ln -s /opt/onap/sdnc /opt/sdnc
RUN mkdir -p /opt/opendaylight/current/certs

# install AAF configs
COPY aaa-app-config.xml $ODL_HOME/etc/opendaylight/datastore/initial/config/
RUN echo "cadi_prop_files=$SDNC_CONFIG_DIR/org.onap.sdnc.props" >> $ODL_HOME/etc/system.properties

# install ssl and java certificates
COPY truststoreONAPall.jks $JAVA_SECURITY_DIR
COPY truststoreONAPall.jks $SDNC_STORE_DIR

RUN keytool -importkeystore -srckeystore $JAVA_SECURITY_DIR/truststoreONAPall.jks -srcstorepass changeit -destkeystore $JAVA_SECURITY_DIR/cacerts  -deststorepass changeit

# Secure with TLS
RUN echo org.osgi.service.http.secure.enabled=true >> $ODL_HOME/etc/custom.properties
RUN echo org.osgi.service.http.secure.port=$SDNC_SECUREPORT >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.keystore=$SDNC_STORE_DIR/$SDNC_KEYSTORE >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.password=$SDNC_KEYPASS >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.keypassword=$SDNC_KEYPASS >> $ODL_HOME/etc/custom.properties

# Create odl user
#RUN adduser odl
#
#RUN chown -R odl /opt
#USER odl

ENTRYPOINT /opt/onap/sdnc/bin/startODL.sh
EXPOSE 8181
