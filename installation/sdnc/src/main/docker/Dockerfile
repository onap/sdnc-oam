FROM ${java.base.image} AS assemble
USER root

ENV ODL_HOME=/opt/opendaylight/current \
    SDNC_CONFIG_DIR=/opt/onap/sdnc/data/properties \
    SDNC_STORE_DIR=/opt/onap/sdnc/data/stores \
    SDNC_KEYSTORE=${sdnc.keystore} \
    SDNC_KEYPASS=${sdnc.keypass} \
    SDNC_SECUREPORT=${sdnc.secureport}

RUN apk add --no-cache zip

COPY sdnc-karaf-${sdnc.karaf.version}.tar.gz /tmp/
RUN mkdir -p /opt/odl \
    && tar xzf /tmp/sdnc-karaf-${sdnc.karaf.version}.tar.gz --directory /opt/odl \
    && rm /tmp/sdnc-karaf-${sdnc.karaf.version}.tar.gz \
    && mv /opt/odl/sdnc-karaf-${sdnc.karaf.version} /opt/opendaylight \
    && rmdir /opt/odl \
    && ln -s /opt/opendaylight /opt/opendaylight/current

RUN sed -i \
        -e '/^log4j2.pattern/s/| %m%n$/| %X{currentGraph} - %X{nodeId} | %m%n/' \
        -e 's/{karaf.log.console:-OFF}/{env:KARAF_CONSOLE_LOG_LEVEL\\:-OFF}/' \
        $ODL_HOME/etc/org.ops4j.pax.logging.cfg \
    && grep -q '^log4j2.pattern.*currentGraph' $ODL_HOME/etc/org.ops4j.pax.logging.cfg \
    && grep -q 'KARAF_CONSOLE_LOG_LEVEL' $ODL_HOME/etc/org.ops4j.pax.logging.cfg

COPY opt/onap /opt/onap
RUN mkdir $ODL_HOME/current/certs

RUN cp $ODL_HOME/etc/org.apache.karaf.features.cfg $ODL_HOME/etc/org.apache.karaf.features.cfg.orig \
    && sed -i -e "\|featuresBoot[^a-zA-Z]|s|$|,${extra.odl.features},${ccsdk.sli.features}|" $ODL_HOME/etc/org.apache.karaf.features.cfg \
    && cp $ODL_HOME/etc/org.apache.karaf.features.cfg $ODL_HOME/etc/org.apache.karaf.features.cfg.sdnc.orig \
    && sed -i -e "\|featuresBoot[^a-zA-Z]|s|$|,${sdnc.features.boot}|" $ODL_HOME/etc/org.apache.karaf.features.cfg \
    && sed -i "s/odl-restconf-all/odl-restconf-all,odl-netconf-topology/g" $ODL_HOME/etc/org.apache.karaf.features.cfg

COPY patches/pax-web-jetty-${odl.ops4j.version}.jar $ODL_HOME/system/org/ops4j/pax/web/pax-web-jetty/${odl.ops4j.version}/
COPY patches/aaa-authn-api-${odl.aaa.version}.jar $ODL_HOME/system/org/opendaylight/aaa/aaa-authn-api/${odl.aaa.version}/

COPY truststoreONAPall.jks $SDNC_STORE_DIR

RUN echo org.osgi.service.http.secure.enabled=true >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.osgi.service.http.port.secure=$SDNC_SECUREPORT >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.ops4j.pax.web.ssl.keystore=$SDNC_STORE_DIR/$SDNC_KEYSTORE >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.ops4j.pax.web.ssl.keystore.type=PKCS12 >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.ops4j.pax.web.ssl.keystore.password="$SDNC_KEYPASS" >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.ops4j.pax.web.ssl.password="$SDNC_KEYPASS" >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.ops4j.pax.web.ssl.key.password="$SDNC_KEYPASS" >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.ops4j.pax.web.ssl.keypassword="$SDNC_KEYPASS" >> $ODL_HOME/etc/org.ops4j.pax.web.cfg \
    && echo org.ops4j.pax.web.ssl.key.alias=sdnc@sdnc.onap.org >> $ODL_HOME/etc/org.ops4j.pax.web.cfg

RUN cp /opt/onap/sdnc/data/properties/svclogic-compiler.properties /opt/onap/sdnc/svclogic/config/svclogic.properties

# Remediate log4shell vuln
RUN find /opt/opendaylight/system/org/ops4j/pax/logging/pax-logging-log4j2 -name 'pax-logging-log4j2*.jar' -exec zip -q -d '{}' org/apache/logging/log4j/core/lookup/JndiLookup.class \;

ENV OTEL_AGENT_VERSION=2.24.0
RUN mkdir -p /opt/opentelemetry && \
    wget -O /opt/opentelemetry/opentelemetry-javaagent.jar \
    https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_AGENT_VERSION}/opentelemetry-javaagent.jar

RUN chmod -R 755 /opt/opendaylight /opt/onap /opt/opentelemetry

#################################################

# Not FROM scratch: keeping the upstream JRE layers lets scanners see the base and lets nodes share it.
FROM ${java.base.image}
LABEL maintainer="SDN-C Team (sdnc@lists.onap.org)"
USER root

RUN apk add --no-cache bash coreutils curl jq mariadb-client mysql-client musl-locales openssl python3 unzip zip \
    && addgroup -S -g ${odl.gid} odl \
    && adduser -S -u ${odl.uid} -G odl odl

ENV LC_ALL=en_US.UTF-8 \
    ODL_HOME=/opt/opendaylight/current \
    SDNC_CONFIG_DIR=/opt/onap/sdnc/data/properties \
    SDNC_KEYSTORE=${sdnc.keystore} \
    SDNC_KEYPASS=${sdnc.keypass} \
    OTEL_JAVAAGENT_PATH=/opt/opentelemetry/opentelemetry-javaagent.jar

COPY --from=assemble --chown=${odl.uid}:${odl.gid} /opt/opendaylight /opt/opendaylight
COPY --from=assemble --chown=${odl.uid}:${odl.gid} /opt/onap /opt/onap
COPY --from=assemble --chown=${odl.uid}:${odl.gid} /opt/opentelemetry /opt/opentelemetry

# Copy any certs
COPY *.md *.pem /etc/ssl/certs/

RUN update-ca-certificates \
    && ln -s /opt/onap/sdnc /opt/sdnc \
    && keytool -importkeystore -srckeystore /opt/onap/sdnc/data/stores/truststoreONAPall.jks -srcstorepass changeit \
       -destkeystore /opt/java/openjdk/lib/security/cacerts -deststorepass changeit -noprompt

USER odl
EXPOSE 8181
WORKDIR ${ODL_HOME}
ENTRYPOINT /opt/onap/sdnc/bin/startODL.sh
