# Prepare stage for multistage image build
## START OF STAGE0 ##
FROM onap/ccsdk-odlsli-alpine-image:${ccsdk.docker.version} AS stage0
USER root

ENV JAVA_HOME /opt/java/openjdk
ENV PATH $PATH:/opt/java/openjdk/bin

ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties
ENV SDNC_STORE_DIR /opt/onap/sdnc/data/stores
ENV JAVA_SECURITY_DIR /opt/java/openjdk/lib/security

ENV SDNC_KEYSTORE ${sdnc.keystore}
ENV SDNC_KEYPASS ${sdnc.keypass}
ENV SDNC_SECUREPORT ${sdnc.secureport}

ARG AAF=false

# Copy any certs
COPY *.md *.pem /etc/ssl/certs/

# Install certs
RUN update-ca-certificates

# Copy deliverables to opt
COPY opt /opt
RUN test -L /opt/sdnc || ln -s /opt/onap/sdnc /opt/sdnc
RUN mkdir $ODL_HOME/current/certs

# Copy SDNC mvn artifacts to ODL repository
COPY system /tmp/system
RUN rsync -a /tmp/system $ODL_HOME

# Backing up existing karaf cfg and updating features boot and features repositories defined in pom.xml
RUN cp $ODL_HOME/etc/org.apache.karaf.features.cfg $ODL_HOME/etc/org.apache.karaf.features.cfg.sdnc.orig
RUN sed -i -e "\|featuresBoot[^a-zA-Z]|s|$|,${sdnc.features.boot}|" $ODL_HOME/etc/org.apache.karaf.features.cfg
RUN sed -i -e "\|featuresRepositories|s|$|,${sdnr.features.repo},${sdnc.features.repo}|" $ODL_HOME/etc/org.apache.karaf.features.cfg

# Add odl-netconf-topology to boot repositories
RUN sed -i "s/odl-restconf-all/odl-restconf-all,odl-netconf-topology/g"  $ODL_HOME/etc/org.apache.karaf.features.cfg

# copy patches
COPY patches/pax-web-jetty-${odl.ops4j.version}.jar $ODL_HOME/system/org/ops4j/pax/web/pax-web-jetty/${odl.ops4j.version}/
COPY patches/aaa-authn-api-${odl.aaa.version}.jar $ODL_HOME/system/org/opendaylight/aaa/aaa-authn-api/${odl.aaa.version}/

# Add aaa-app-config.xml Only if AAF is set to true (being passed as an argument in docker-maven-plugin configuration)
COPY aaa-app-config.xml /tmp/aaa-app-config.xml
RUN if "${AAF}" ; then \
        mkdir -p $ODL_HOME/etc/opendaylight/datastore/initial/config ;\
        mv /tmp/aaa-app-config.xml $ODL_HOME/etc/opendaylight/datastore/initial/config/. ;\
        echo "cadi_prop_files=$SDNC_CONFIG_DIR/org.onap.sdnc.props" >> $ODL_HOME/etc/system.properties ;\
    fi

# Install ssl and java certificates
COPY truststoreONAPall.jks $SDNC_STORE_DIR
RUN if [ -f $JAVA_SECURITY_DIR}/cacerts ] ; then keytool -importkeystore -srckeystore $SDNC_STORE_DIR/truststoreONAPall.jks -srcstorepass changeit -destkeystore $JAVA_SECURITY_DIR/cacerts  -deststorepass changeit -noprompt ; fi
RUN keytool -importkeystore -srckeystore $SDNC_STORE_DIR/truststoreONAPall.jks -srcstorepass changeit -destkeystore /opt/java/openjdk/lib/security/cacerts  -deststorepass changeit -noprompt

# Secure with TLS
#RUN echo org.osgi.service.http.secure.enabled=true >> $ODL_HOME/etc/custom.properties
RUN echo org.osgi.service.http.secure.port=$SDNC_SECUREPORT >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.keystore=$SDNC_STORE_DIR/$SDNC_KEYSTORE >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.password=\"$SDNC_KEYPASS\" >> $ODL_HOME/etc/custom.properties
RUN echo org.ops4j.pax.web.ssl.keypassword=\"$SDNC_KEYPASS\" >> $ODL_HOME/etc/custom.properties

# Overwrite svclogic compiler properties
RUN cp /opt/onap/sdnc/data/properties/svclogic-compiler.properties /opt/onap/sdnc/svclogic/config/svclogic.properties

# Short term fix starts: for javax.servlet-api bundle (Replacing 4.0.1 to 3.1.0 as it's unique for javax.servlet-api)
RUN find /opt/opendaylight -name "*features*.xml" -exec sed -i -e 's|4.0.1|3.1.0|g' {} \;
# Short term fix ends

# Remediate log4shell vuln
RUN apk add zip
RUN find /opt/opendaylight/system/org/ops4j/pax/logging/pax-logging-log4j2 -name 'pax-logging-log4j2*.jar' -exec zip -q -d '{}' org/apache/logging/log4j/core/lookup/JndiLookup.class \;


# Changing ownership and permission of /opt
RUN chown -R odl:odl /opt && chmod -R 755 /opt



## END OF STAGE0 ##

#################################################

## This will create actual image
FROM scratch
LABEL maintainer="SDN-C Team (sdnc@lists.onap.org)"
USER root

ENV LC_ALL=en_US.UTF-8 \
    JAVA_HOME=/opt/java/openjdk \
    PATH=$PATH:/opt/java/openjdk/bin \
    ODL_HOME=/opt/opendaylight/current \
    SDNC_CONFIG_DIR=/opt/onap/sdnc/data/properties \
    SDNC_KEYSTORE=${sdnc.keystore} \
    SDNC_KEYPASS=${sdnc.keypass}

# Copy Everything from stage0
COPY --from=stage0 / /

USER odl
EXPOSE 8181
WORKDIR ${ODL_HOME}
ENTRYPOINT /opt/onap/sdnc/bin/startODL.sh
