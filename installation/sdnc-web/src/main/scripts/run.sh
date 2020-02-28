#!/bin/bash

###
#============LICENSE_START=======================================================
# ONAP : ccsdk distribution web
#================================================================================
# Copyright (C) 2020 highstreet technologies GmbH Intellectual Property.
# All rights reserved.
#================================================================================
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
#============LICENSE_END=========================================================
###
 
/opt/bitnami/nginx/sbin/configure.sh

echo "starting sdnc-web"
echo "================="
echo " WEBPROTOCOL: $WEBPROTOCOL"
echo " WEBPORT: $WEBPORT"
echo " SDNRPROTOCOL: $SDNRPROTOCOL"
echo " SDNRHOST: $SDNRHOST"
echo " SDNRPORT: $SDNRPORT"
echo " LOCALDNS: $LOCALDNS"
echo " SSL_CERT_DIR: $SSL_CERT_DIR"
echo -n " SSL_CERTIFICATE: $SSL_CERTIFICATE"
if [ -f "$SSL_CERTIFICATE" ]; then
echo " (exists)"
else
echo " (missing)"
fi
echo -n " SSL_CERTIFICATE_KEY: $SSL_CERTIFICATE_KEY"
if [ -f "$SSL_CERTIFICATE_KEY" ]; then
echo " (exists)"
else
echo " (missing)"
fi
echo ""

if [ ! -z "$DEBUG" ]; then

  if [ -f "/opt/bitnami/nginx/conf/server_blocks/http_site.conf" ]; then
    echo "content of /opt/bitnami/nginx/conf/server_blocks/http_site.conf"
    echo "==============================================================="
    cat /opt/bitnami/nginx/conf/server_blocks/http_site.conf
    echo "==============================================================="
  fi

  if [ -f "/opt/bitnami/nginx/conf/server_blocks/https_site.conf" ]; then
    echo "content of /opt/bitnami/nginx/conf/server_blocks/https_site.conf"
    echo "==============================================================="
    cat /opt/bitnami/nginx/conf/server_blocks/https_site.conf
    echo "==============================================================="
  fi

  #tail -f /opt/bitnami/nginx/logs/* &
fi

# Call the base images' run.sh to start NGINX
bash /run.sh