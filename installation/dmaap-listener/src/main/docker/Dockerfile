# Base ubuntu with added packages needed for open ecomp
FROM onap/ccsdk-alpine-j11-image:${ccsdk.docker.version} AS stage0

ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties

# copy deliverables to opt
COPY opt /opt

# End of stage 0

FROM onap/ccsdk-alpine-j11-image:${ccsdk.docker.version}

MAINTAINER SDNC Team (onap-sdnc@lists.onap.org)

ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties

USER root
RUN apk update && apk add \
    bash \
    git \
    maven \
    mysql-client \
    nodejs \
    py3-pip \
    graphviz \
    unzip \
    rsync


# Create sdnc user
RUN addgroup -S sdnc && adduser -S sdnc -G sdnc


# Copy /opt and change owner/group to sdnc
COPY --from=stage0 --chown=sdnc:sdnc /opt /opt

USER sdnc