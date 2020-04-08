# Base ubuntu with added packages needed for open ecomp
FROM alpine:3.8 AS stage0

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties

# copy deliverables to opt
COPY opt /opt

# End of stage 0

FROM alpine:3.8

MAINTAINER SDNC Team (onap-sdnc@lists.onap.org)

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV SDNC_CONFIG_DIR /opt/onap/sdnc/data/properties

USER root
RUN apk update && apk add \
    bash \
    git \
    openjdk8 \
    maven \
    mysql-client \
    nodejs \
    py-pip \
    graphviz \
    unzip \
    rsync

# Enable wheel group
RUN sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' -i /etc/sudoers

# Create sdnc user
RUN addgroup -S sdnc && adduser -S sdnc -G sdnc
RUN addgroup sdnc wheel

# Copy /opt and change owner/group to sdnc
COPY --from=stage0 --chown=sdnc:sdnc /opt /opt

USER sdnc