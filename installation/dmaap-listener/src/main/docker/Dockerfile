FROM ${java.base.image} AS stage0
USER root

# Copy any certs
COPY *.md *.pem /etc/ssl/certs/

# copy deliverables to opt
COPY opt /opt

# Remediate log4shell vuln
RUN apk add --no-cache zip \
    && zip -q -d /opt/onap/sdnc/dmaap-listener/lib/log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class

# End of stage0

FROM ${java.base.image}
LABEL maintainer="SDNC Team (onap-sdnc@lists.onap.org)"
USER root

# start-dmaap-listener.sh only falls back to its own JAVA_OPTS when this is unset; the listener has always run with these.
ENV SDNC_CONFIG_DIR=/opt/onap/sdnc/data/properties \
    JAVA_OPTS="-Xms256m -Xmx1g" \
    JAVA_SEC_OPTS=""

RUN apk add --no-cache bash \
    && addgroup -S -g 102 sdnc \
    && adduser -S -u 100 -G sdnc sdnc

COPY --from=stage0 /etc/ssl/certs /etc/ssl/certs
RUN update-ca-certificates

COPY --from=stage0 --chown=sdnc:sdnc /opt/onap /opt/onap

USER sdnc
