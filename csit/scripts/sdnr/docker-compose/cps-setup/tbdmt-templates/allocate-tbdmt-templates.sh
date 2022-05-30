#!/bin/bash

CPS_TBDMT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdnr-cps-tbdmt )

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "get-cells-list",
"model": "ran-coverage-area",
"requestType": "query-cps-path",
"xpathTemplate": "//coverageAreaTAList[@nRTAC={{nRTAC}}]",
"includeDescendants": true,
"transformParam": "coverageAreaTAList"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "get-ric-from-cell-id",
"model": "ran-network",
"requestType": "query-cps-path",
"xpathTemplate": "//NRCellDU[@idNRCellDU='\''{{idNRCellDU}}'\'']/ancestor::NearRTRIC",
"includeDescendants": true,
"transformParam": "NearRTRIC"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-nearrtric",
"model": "ran-network",
"requestType": "put",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']",
"includeDescendants": true
}'

curl -location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-slice-profile",
"model": "ran-network",
"requestType": "post-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/attributes"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-snssai-nrcellcu",
"model": "ran-network",
"requestType": "put",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUCPFunction[@idGNBCUCPFunction='\''{{idGNBCUCPFunction}}'\'']/NRCellCU[@idNRCellCU='\''{{idNRCellCU}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-nrcellcu-rrm-policy",
"model": "ran-network",
"requestType": "post-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUCPFunction[@idGNBCUCPFunction='\''{{idGNBCUCPFunction}}'\'']/NRCellCU[@idNRCellCU='\''{{idNRCellCU}}'\'']/attributes",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-snssai-cuup",
"model": "ran-network",
"requestType": "put",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUUPFunction[@idGNBCUUPFunction='\''{{idGNBCUUPFunction}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-cuup-rrm-policy",
"model": "ran-network",
"requestType": "post-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUUPFunction[@idGNBCUUPFunction='\''{{idGNBCUUPFunction}}'\'']/attributes",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-nrcelldu-snssai",
"model": "ran-network",
"requestType": "put",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBDUFunction[@idGNBDUFunction='\''{{idGNBDUFunction}}'\'']/NRCellDU[@idNRCellDU='\''{{idNRCellDU}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "add-nrcelldu-rrm-policy",
"model": "ran-network",
"requestType": "post-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBDUFunction[@idGNBDUFunction='\''{{idGNBDUFunction}}'\'']/NRCellDU[@idNRCellDU='\''{{idNRCellDU}}'\'']/attributes",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "ran-inventory-new-slice",
"model": "ran-inventory",
"requestType": "post-list-node",
"xpathTemplate": "/ran-inventory",
"includeDescendants": true
}'
