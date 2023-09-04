#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Modifications copyright (c) 2017 AT&T Intellectual Property
# Modifications copyright (c) 2022 highstreet technologies GmbH Property
#

# Remove all not needed images and clean workspace
sudo apt clean
docker rmi -f $(docker images onap/sdnc-dmaap-listener-image -a -q)
docker rmi -f $(docker images onap/sdnc-ueb-listener-image -a -q)
docker rmi -f $(docker images onap/onap/sdnc-web-image -a -q)
docker rmi -f $(docker images onap/sdnc-ansible-server-image -a -q)
docker rmi -f $(docker images onap/sdnc-aaf-image -a -q)
docker rmi -f $(docker images onap/ccsdk-ansible-server-image -a -q)
docker rmi -f $(docker images onap/ccsdk-odlsli-alpine-image -a -q)
docker images

echo "Start plan sdnr"

source ${WORKSPACE}/scripts/sdnr/sdnr-launch.sh
onap_dependent_components_launch
nts_networkfunctions_launch ${WORKSPACE}/plans/sdnr/testdata/nts-networkfunctions.csv
sdnr_web_launch

## environment for SDNC/R specific robot test runs
## Ready state will be checked every SDNC_READY_RETRY_PERIOD seconds
# SDNC_READY_RETRY_PERIOD=15
## SDNC ready state will be checked max SDNC_READY_TIMEOUT seconds
# SDNC_READY_TIMEOUT=450

## if jenkins should be ok without running robots TCS's
#SDNC_RELEASE_WITHOUT_ROBOT=true

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_DEBUG_LEVEL=DEBUG # INFO or DEBUG

ROBOT_VARIABLES="--variablefile=${WORKSPACE}/plans/sdnr/testdata/localhost.py -L ${ROBOT_DEBUG_LEVEL}"
ROBOT_IMAGE="hightec/sdnc-test-lib:v0.12.0"

