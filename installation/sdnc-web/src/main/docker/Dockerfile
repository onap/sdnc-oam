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
MAINTAINER CCSDK Team (onap-ccsdk@lists.onap.org)

# copy ODLUX files to nginx
COPY html /opt/bitnami/nginx/html  

# copy site conf files 
COPY http_site.conf /opt/bitnami/nginx/conf/server_blocks/
COPY https_site.conf /opt/bitnami/nginx/conf/server_blocks/

# setup environment variables
ENV WEBPROTOCOL="HTTP" \
	WEBPORT="8080" \
	SDNRPROTOCOL="HTTP" \
	SDNRHOST="172.18.0.3" \
	SDNRPORT="8181" \
	LOCALDNS="127.0.0.11" \
	SSL_CERT_DIR="/app/cert" \
	SSL_CERTIFICATE="cert.pem" \
	SSL_CERTIFICATE_KEY="cert.key"

# Check if /app can be used. If so, create "custom" directory and copy the files there.
COPY bin/configure.sh /opt/bitnami/nginx/sbin
COPY bin/run.sh /opt/bitnami/nginx/sbin

USER root
RUN chmod +x /opt/bitnami/nginx/sbin/configure.sh
RUN chmod +x /opt/bitnami/nginx/sbin/run.sh
# By default, docker copies files with the permissions of the build user. To avoid cases where build user 
# has 644 which can result in failure of certain commands
RUN chmod -R g+w /opt/bitnami/nginx/html/odlux

USER 1001
CMD [ "/opt/bitnami/nginx/sbin/run.sh" ]

