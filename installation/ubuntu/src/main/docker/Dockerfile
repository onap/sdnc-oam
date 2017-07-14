# Base ubuntu with added packages needed for open ecomp
FROM ubuntu:16.04
MAINTAINER SDN-C Team (sdnc@lists.openecomp.org)

ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV HTTP_PROXY  ${HTTP_PROXY}
ENV HTTPS_PROXY ${HTTPS_PROXY}

RUN if [ ! -z ${HTTP_PROXY} ]; then echo "Acquire::http::proxy  \"${HTTP_PROXY}\";" >> /etc/apt/apt.conf; fi && \
    if [ ! -z ${HTTPS_PROXY} ]; then echo "Acquire::https::proxy \"${HTTPS_PROXY}\";" >> /etc/apt/apt.conf; fi

# Add tools needed for OpenDaylight
RUN apt-get update && apt-get install -y git \
    graphviz \
    openjdk-8-jdk \
    maven \
    mysql-client 
    nodejs \
    nodejs-legacy \
    npm \
    python-pip \
    unzip
