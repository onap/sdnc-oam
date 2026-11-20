FROM ${java.base.image} AS stage0
USER root

# Copy any certs
COPY *.md *.pem /etc/ssl/certs/

# copy deliverables to opt
COPY opt /opt

# Remediate log4shell vuln
RUN apk add --no-cache zip \
    && zip -q -d /opt/onap/sdnc/ueb-listener/lib/log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class

ENV OTEL_AGENT_VERSION=2.24.0
RUN mkdir -p /opt/opentelemetry && \
    wget -O /opt/opentelemetry/opentelemetry-javaagent.jar \
    https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_AGENT_VERSION}/opentelemetry-javaagent.jar

# End of stage0

FROM ${java.base.image}
LABEL maintainer="SDNC Team (onap-sdnc@lists.onap.org)"
USER root

# start-ueb-listener.sh only falls back to its own JAVA_OPTS when this is unset.
ENV SDNC_CONFIG_DIR=/opt/onap/sdnc/data/properties \
    JAVA_OPTS="-XX:MaxRAMPercentage=75.0" \
    JAVA_SEC_OPTS="" \
    OTEL_JAVAAGENT_PATH=/opt/opentelemetry/opentelemetry-javaagent.jar

RUN apk add --no-cache bash \
    && addgroup -S -g 102 sdnc \
    && adduser -S -u 100 -G sdnc sdnc

COPY --from=stage0 /etc/ssl/certs /etc/ssl/certs
RUN update-ca-certificates

COPY --from=stage0 --chown=sdnc:sdnc /opt/onap /opt/onap
COPY --from=stage0 --chown=sdnc:sdnc /opt/opentelemetry /opt/opentelemetry

USER sdnc
