#!/bin/bash

###
# ============LICENSE_START=======================================================
# Copyright (C) 2020 Nordix Foundation. All rights reserved.
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

SDNC_STORE_DIR=${SDNC_STORE_DIR:-/opt/onap/sdnc/data/stores}
A1_TRUSTSTORE=${SDNC_STORE_DIR}/truststore.a1.adapter.jks
ONAP_TRUSTSTORE=${SDNC_STORE_DIR}/truststoreONAPall.jks

if [ -f ${A1_TRUSTSTORE} -a "${A1_TRUSTSTORE_PASSWORD}" != "" ]
then
  keytool -importkeystore -srckeystore ${A1_TRUSTSTORE} -srcstorepass ${A1_TRUSTSTORE_PASSWORD} -destkeystore ${ONAP_TRUSTSTORE} -deststorepass changeit
fi
