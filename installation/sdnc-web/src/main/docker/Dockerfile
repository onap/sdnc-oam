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

FROM ${base.image.repo}
LABEL maintainer="CCSDK Team (onap-ccsdk@lists.onap.org)"
USER root
RUN apk add --no-cache bash sed python3 py3-urllib3 unzip openssl

COPY nginx/nginx.conf /etc/nginx/nginx.conf
# copy ODLUX files to nginx
COPY html /app

# copy site conf files
COPY conf/* /etc/nginx/server_blocks/

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

COPY bin/* /opt/sdnc-web/bin/

RUN chmod +x /opt/sdnc-web/bin/run.sh /opt/sdnc-web/bin/opm.py \
    && mkdir /app/init.d \
    && chown -R 1001:0 /app /etc/nginx/server_blocks \
    && chmod -R g+w /app /etc/nginx/server_blocks \
    && ln -s /opt/sdnc-web/bin/opm.py /usr/local/bin/opm
USER 1001
CMD [ "/opt/sdnc-web/bin/run.sh" ]
