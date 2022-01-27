#!/bin/bash

###
# ============LICENSE_START=======================================================
# ONAP : ccsdk distribution web
# ================================================================================
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

# load core methods to call
from core import *

# Comment listening on 8080 in nginx.conf as we don't want nginx to listen on any port other than SDNR
sedInFile('listen','\#listen', '/opt/bitnami/nginx/conf/nginx.conf')
initial_load()
update_index_html()

check_for_rule_template()

update_nginx_site_conf()
