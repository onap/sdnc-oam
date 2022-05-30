#!/bin/bash

CPS_TBDMT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdnr-cps-tbdmt )


curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "get-nearrtric-by-rannfnssi",
"model": "ran-network",
"requestType": "query-cps-path",
"xpathTemplate": "//attributes/rANNFNSSIList[text()='\''{{rANNFNSSIId}}'\'']/ancestor::NearRTRIC",
"includeDescendants": true,
"transformParam": "NearRTRIC"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "get-plmnmccid-by-sliceprofileid",
"model": "ran-network",
"requestType": "query-cps-path",
"xpathTemplate": "//attributes/sliceProfilesList[@sliceProfileId='\''{{sliceProfileId}}'\'']/ancestor::NearRTRIC",
"includeDescendants": true,
"transformParam":"NearRTRIC,attributes,pLMNInfoList,mcc"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "get-plmnmncid-by-sliceprofileid",
"model": "ran-network",
"requestType": "query-cps-path",
"xpathTemplate": "//attributes/sliceProfilesList[@sliceProfileId='\''{{sliceProfileId}}'\'']/ancestor::NearRTRIC",
"includeDescendants": true,
"transformParam":"NearRTRIC,attributes,pLMNInfoList,mnc"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "put-status-nearrtric",
"model": "ran-network",
"requestType": "patch",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "put-status-gnbcuup",
"model": "ran-network",
"requestType": "patch",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUUPFunction[@idGNBCUUPFunction='\''{{idGNBCUUPFunction}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "put-status-nrcellcu",
"model": "ran-network",
"requestType": "patch",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUCPFunction[@idGNBCUCPFunction='\''{{idGNBCUCPFunction}}'\'']/NRCellCU[@idNRCellCU='\''{{idNRCellCU}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "put-status-nrcelldu",
"model": "ran-network",
"requestType": "patch",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBDUFunction[@idGNBDUFunction='\''{{idGNBDUFunction}}'\'']/NRCellDU[@idNRCellDU='\''{{idNRCellDU}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']",
"includeDescendants": true
}'

