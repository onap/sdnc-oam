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
# Modifications copyright (c) 2018 AT&T Intellectual Property
# Modifications copyright (C) 2022 highstreet technologies GmbH Intellectual Property
#

if [[ -z $WORKSPACE ]]; then
	CUR_PATH="`dirname \"$0\"`"              # relative path
	CUR_PATH="`( cd \"$CUR_PATH\" && pwd )`"  # absolutized and normalized
	if [ -z "$CUR_PATH" ] ; then
		echo "Permission error!"
		exit 1
	fi

	# define location of workpsace based on where the current script is
	WORKSPACE=$(cd $CUR_PATH/../../ && pwd)
fi

if [[ -z $SCRIPTS ]]; then
	SCRIPTS=$(cd $WORKSPACE/scripts && pwd)
fi

source ${SCRIPTS}/sdnr/sdnrEnv_Common.sh
env_file="--env-file ${SCRIPTS}/sdnr/docker-compose/.env"

function sdnr_teardown() {
	running_containers=$(docker ps -a --format "{{.Names}}")
	if [ -z "$running_containers" ]
	then
		echo "No containers to get logs from!"
	else
		echo "Getting logs from containers!"
		running_containers_array=($(echo "$running_containers" | tr ' ' '\n'))
		mkdir -p ${WORKSPACE}/archives/getallinfo
		for i in "${running_containers_array[@]}"
		do
			echo "Getting logs from container $i"
			docker logs $i >> ${WORKSPACE}/archives/getallinfo/$i.log 2>&1
		done
        docker cp sdnr:/opt/opendaylight/data/log/karaf.log ${WORKSPACE}/archives/getallinfo/sdnr_karaf.log
        docker cp sdnr:/opt/opendaylight/data/log/installCerts.log ${WORKSPACE}/archives/getallinfo/sdnr_installCerts.log
        docker cp sdnr:/opt/opendaylight/etc/custom.properties ${WORKSPACE}/archives/getallinfo/sdnr_custom_properties.log
	fi
	echo "Starting teardown!"
	# removes sdnrdb, sdnr AND all of the rest of the containers (--remove-orphans)
	docker rm -f $(docker ps -aq -f name=ntsim*)
	docker rm -f $(docker ps -aq -f name=nts-*)
	docker rm -f $(docker ps -aq -f name=NTS_Manager*)
	docker rm -f $(docker ps -aq -f name=NTS-Manager*)
	docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-single-sdnr.yaml down --remove-orphans
	docker network rm integration
}
