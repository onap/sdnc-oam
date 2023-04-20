###
#============LICENSE_START=======================================================
# ONAP : ccsdk distribution web
#  ================================================================================
# Copyright (C) 2020 highstreet technologies GmbH Intellectual Property.
# All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================
###

# Base bitnami nginx image
FROM ${base.image.repo}
LABEL maintainer="CCSDK Team (onap-ccsdk@lists.onap.org)"
USER root
RUN apt-get update && apt-get install python3-minimal python3-urllib3 unzip openssl -y
USER 1001
# copy ODLUX files to nginx
COPY html /opt/bitnami/nginx/html  

# copy site conf files 
COPY conf/* /opt/bitnami/nginx/conf/server_blocks/

# setup environment variables
ENV WEBPROTOCOL="HTTP" \
    WEBPORT="8080" \
    SDNRPROTOCOL="HTTP" \
    SDNRHOST="172.18.0.3" \
    SDNRPORT="8181" \
    SDNRWEBSOCKETPORT="8182" \
    TRPCEURL="" \
    TOPOURL="" \
    TILEURL="" \
    SITEDOCURL="" \
    DNS_RESOLVER="1.1.1.1 ipv6=off" \
    DNS_INTERNAL_RESOLVER="127.0.0.11" \
    SSL_CERT_DIR="/app/cert" \
    SSL_CERTIFICATE="cert.pem" \
    SSL_CERTIFICATE_KEY="cert.key"

# Check if /app can be used. If so, create "custom" directory and copy the files there.
COPY bin/* /opt/bitnami/nginx/sbin/ 

USER root
RUN chmod +x /opt/bitnami/nginx/sbin/run.sh /opt/bitnami/nginx/sbin/opm.py
# By default, docker copies files with the permissions of the build user. To avoid cases where build user 
# has 644 which can result in failure of certain commands
RUN chmod -R g+w /opt/bitnami/nginx/html/odlux && mkdir /app/init.d
RUN chmod 666 /opt/bitnami/nginx/conf/server_blocks/*.rules
#RUN chown 1001:1001 /app/odlux.application.list && chmod 777 /app/odlux.application.list
RUN chown -R 1001:1001 /app
RUN ln -s /opt/bitnami/nginx/sbin/opm.py /usr/local/bin/opm
USER 1001
CMD [ "/opt/bitnami/nginx/sbin/run.sh" ]

