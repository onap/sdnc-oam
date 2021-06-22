# Prepare stage for multistage image build
## START OF STAGE0 ##
FROM onap/ccsdk-odlsli-alpine-image:${ccsdk.docker.version} AS stage0

USER root

# copy onap
COPY opt /opt
RUN test -L /opt/sdnc || ln -s /opt/onap/sdnc /opt/sdnc
RUN mkdir $ODL_HOME/current/certs

# copy SDNC mvn artifacts to ODL repository
COPY system /tmp/system
RUN rsync -a /tmp/system $ODL_HOME
## END OF STAGE0 ##

FROM onap/ccsdk-odlsli-alpine-image:${ccsdk.docker.version}

LABEL maintainer="SDN-C Team (sdnc@lists.onap.org)"

ENV PATH=$PATH:/opt/java/openjdk/bin
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties
ENV SDNC_STORE_DIR /opt/onap/sdnc/data/stores
ENV SSL_CERTS_DIR /etc/ssl/certs
ENV JAVA_SECURITY_DIR $SSL_CERTS_DIR/java
ENV SDNC_NORTHBOUND_REPO mvn:org.onap.sdnc.northbound/sdnc-northbound-all/${sdnc.northbound.version}/xml/features
ENV SDNC_KEYSTORE ${sdnc.keystore}
ENV SDNC_KEYPASS ${sdnc.keypass}
ENV SDNC_SECUREPORT ${sdnc.secureport}
ENV CCSDKFEATUREVERSION ${ccsdk.features.version}

USER root

COPY --from=stage0 --chown=odl:odl /opt /opt

# Add SDNC repositories to boot repositories
RUN cp $ODL_HOME/etc/org.apache.karaf.features.cfg $ODL_HOME/etc/org.apache.karaf.features.cfg.orig
RUN sed -i -e "\|featuresRepositories|s|$|,${SDNC_NORTHBOUND_REPO}|"  $ODL_HOME/etc/org.apache.karaf.features.cfg
RUN sed -i -e "\|featuresBoot[^a-zA-Z]|s|$|,sdnc-northbound-all|"  $ODL_HOME/etc/org.apache.karaf.features.cfg
RUN sed -i "s/odl-restconf-all/odl-restconf-all,odl-netconf-topology/g"  $ODL_HOME/etc/org.apache.karaf.features.cfg

# Install ssl and java certificates
COPY truststoreONAPall.jks $SDNC_STORE_DIR
RUN if [ -f $JAVA_SECURITY_DIR}/cacerts ] ; then keytool -importkeystore -srckeystore $SDNC_STORE_DIR/truststoreONAPall.jks -srcstorepass changeit -destkeystore $JAVA_SECURITY_DIR/cacerts  -deststorepass changeit -noprompt ; fi
RUN keytool -importkeystore -srckeystore $SDNC_STORE_DIR/truststoreONAPall.jks -srcstorepass changeit -destkeystore /opt/java/openjdk/lib/security/cacerts  -deststorepass changeit -noprompt


# Secure with TLS
RUN echo org.osgi.service.http.secure.enabled=true >> $ODL_HOME/etc/custom.properties
RUN echo org.osgi.service.http.secure.port=$SDNC_SECUREPORT >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.keystore=$SDNC_STORE_DIR/$SDNC_KEYSTORE >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.password=$SDNC_KEYPASS >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.keypassword=$SDNC_KEYPASS >> $ODL_HOME/etc/custom.properties

# Overwrite svclogic compiler properties
RUN cp /opt/onap/sdnc/data/properties/svclogic-compiler.properties /opt/onap/sdnc/svclogic/config/svclogic.properties
RUN chown -R odl:odl /opt

USER odl

ENTRYPOINT /opt/onap/sdnc/bin/startODL.sh
EXPOSE 8181
