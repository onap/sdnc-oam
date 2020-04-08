# Base alpine with added packages needed for open ecomp
FROM onap/ccsdk-alpine-image:${ccsdk.docker.version} AS stage0

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties


# copy deliverables to opt
COPY opt /opt

# End of stage0

FROM onap/ccsdk-alpine-image:${ccsdk.docker.version}
MAINTAINER SDNC Team (onap-sdnc@lists.onap.org)

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties

USER root


# Create sdnc user
RUN addgroup -S sdnc && adduser -S sdnc -G sdnc

# Copy /opt and change user/owner to sdnc
COPY --from=stage0 --chown=sdnc:sdnc /opt /opt

USER sdnc