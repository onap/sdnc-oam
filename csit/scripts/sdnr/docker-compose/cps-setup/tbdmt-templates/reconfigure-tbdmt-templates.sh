#!/bin/bash

CPS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdnr-cps )
echo $CPS_IP
CPS_TBDMT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdnr-cps-tbdmt )
echo $CPS_TBDMT_IP


#reconfigure templates

#get-plmnid
curl --location --request POST 'http://localhost:8088/templates' \
--header 'Content-Type: application/json' \
--data-raw '{
"templateId": "get-plmnid",
"model": "ran-inventory",
"requestType": "query-cps-path",
"xpathTemplate": "//sliceProfilesList[@sliceProfileId='\''{{sliceProfileId}}'\'']",
"includeDescendants": true,
"transformParam":"sliceProfilesList,pLMNIdList"
}'

#patch-configData
curl --location --request POST 'http://localhost:8088/templates' \
--header 'Content-Type: application/json' \
--data-raw '{
"templateId": "patch-configData",
"model": "ran-network",
"requestType": "patch",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']/sNSSAIList[@sNssai='\''{{sNssai}}'\'']",
"includeDescendants": true
}'

#patch-cell-configData
curl --location --request POST 'http://localhost:8088/templates' \
--header 'Content-Type: application/json' \
--data-raw '{
"templateId": "patch-cell-configData",
"model": "ran-network",
"requestType": "patch",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUCPFunction[@idGNBCUCPFunction='\''{{idGNBCUCPFunction}}'\'']/NRCellCU[@idNRCellCU='\''{{idNRCellCU}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']/sNSSAIList[@sNssai='\''{{sNssai}}'\'']",
"includeDescendants": true
}'
