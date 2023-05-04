# Base alpine with added packages needed for open ecomp
FROM onap/ccsdk-alpine-j17-image:${ccsdk.docker.version} AS stage0
USER root
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties


# copy deliverables to opt
COPY opt /opt

# Remediate log4shell vuln
RUN apk add zip
RUN zip -q -d /opt/onap/sdnc/ueb-listener/lib/log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class



# End of stage0

FROM onap/ccsdk-alpine-j17-image:${ccsdk.docker.version}
MAINTAINER SDNC Team (onap-sdnc@lists.onap.org)

ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties

USER root


# Create sdnc user
RUN addgroup -S sdnc && adduser -S sdnc -G sdnc

# Copy /opt and change user/owner to sdnc
COPY --from=stage0 --chown=sdnc:sdnc /opt /opt

USER sdnc
