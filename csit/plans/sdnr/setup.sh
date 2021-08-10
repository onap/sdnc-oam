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
# Modifications copyright (c) 2021 highstreet technologies GmbH Property
#

echo "Clean"
sudo apt clean

echo "Start plan sdnr"

docker image prune -f
echo "Should be empty"
docker ps -a
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images onap/sdnc-ansible-server-image -a -q)
docker rmi -f $(docker images onap/sdnc-aaf-image -a -q)
docker rmi -f $(docker images onap/ccsdk-ansible-server-image -a -q)
docker rmi -f $(docker images onap/ccsdk-odlsli-alpine-image -a -q)
docker rmi -f $(docker images onap/ccsdk-alpine-j11-image -a -q)
docker images

source ${WORKSPACE}/scripts/sdnr/sdnr-launch.sh
onap_dependent_components_launch
nts_networkfunctions_launch ${WORKSPACE}/plans/sdnr/testdata/nts-networkfunctions.csv
sdnr_launch

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="--variablefile=${WORKSPACE}/plans/sdnr/testdata/localhost.py"
ROBOT_IMAGE="hightec/sdnc-test-lib:latest"
