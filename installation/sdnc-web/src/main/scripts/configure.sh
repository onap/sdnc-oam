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

# Comment listening on 8080 in nginx.conf as we don't want nginx to listen on any port other than SDNR
sed -i 's/listen/\#listen/g' /opt/bitnami/nginx/conf/nginx.conf

update_index_html() {
 
	# Backup the index.html file
	cp /opt/bitnami/nginx/html/odlux/index.html /opt/bitnami/nginx/html/odlux/index.html.backup
	sed -z 's/<script>[^<]*<\/script>/<script>\n    \/\/ run the application \n  require\(\[\"connectApp\",\"faultApp\",\"maintenanceApp\",\"configurationApp\",\"performanceHistoryApp\",\"inventoryApp\",\"eventLogApp\",\"mediatorApp\",\"helpApp\",\"run\"\], function \(connectApp,faultApp,maintenanceApp,configurationApp,performanceHistoryApp,inventoryApp,eventLogApp,mediatorApp,helpApp,run\) \{ \n    connectApp.register\(\); \n  faultApp.register\(\);\n    maintenanceApp.register\(\); \n     configurationApp.register\(\);\n    performanceHistoryApp.register\(\); \n    inventoryApp.register\(\);\n    eventLogApp.register\(\);\n   mediatorApp.register\(\);\n     helpApp.register\(\);\n      run.runApplication();\n    \}\);\n  <\/script>/' -i /opt/bitnami/nginx/html/odlux/index.html 

}

update_nginx_site_conf() {
	
	if [ "$WEBPROTOCOL" == "HTTPS" ]
	then
		
		sed -i 's|WEBPORT|'$WEBPORT'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		sed -i 's|SSL_CERT_DIR|'$SSL_CERT_DIR'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		sed -i 's|\bSSL_CERTIFICATE\b|'$SSL_CERTIFICATE'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		sed -i 's|\bSSL_CERTIFICATE_KEY\b|'$SSL_CERTIFICATE_KEY'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		sed -i 's|SDNRPROTOCOL|'$SDNRPROTOCOL'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		sed -i 's|SDNRHOST|'$SDNRHOST'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		sed -i 's|SDNRPORT|'$SDNRPORT'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		sed -i 's|LOCALDNS|'$LOCALDNS'|g' /opt/bitnami/nginx/conf/server_blocks/https_site.conf
		
		#cp /opt/bitnami/nginx/sbin/https_site.conf /opt/bitnami/nginx/conf/server_blocks
		rm /opt/bitnami/nginx/conf/server_blocks/http_site.conf
	elif [ "$WEBPROTOCOL" == "HTTP" ]
	then
		sed -i 's|WEBPORT|'$WEBPORT'|g' /opt/bitnami/nginx/conf/server_blocks/http_site.conf
		sed -i 's|SDNRPROTOCOL|'$SDNRPROTOCOL'|g' /opt/bitnami/nginx/conf/server_blocks/http_site.conf
		sed -i 's|SDNRHOST|'$SDNRHOST'|g' /opt/bitnami/nginx/conf/server_blocks/http_site.conf
		sed -i 's|SDNRPORT|'$SDNRPORT'|g' /opt/bitnami/nginx/conf/server_blocks/http_site.conf
		sed -i 's|LOCALDNS|'$LOCALDNS'|g' /opt/bitnami/nginx/conf/server_blocks/http_site.conf
		#cp /opt/bitnami/nginx/sbin/http_site.conf /opt/bitnami/nginx/conf/server_blocks
		rm /opt/bitnami/nginx/conf/server_blocks/https_site.conf
	fi

}

update_index_html

update_nginx_site_conf
