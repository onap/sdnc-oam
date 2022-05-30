#!/bin/bash

CPS_TBDMT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdnr-cps-tbdmt )
echo $CPS_TBDMT_IP

#terminate tbdmt templates

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "get-nearrtric-by-rannfnssi",
"model": "dynamic",
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
"templateId": "delete-nssai-from-rtric",
"model": "ran-network",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']/sNSSAIList[@sNssai='\''{{sNSSAIList}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nssai-from-cucp-plmninfo",
"model": "ran-network",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUCPFunction[@idGNBCUCPFunction='\''{{idGNBCUCPFunction}}'\'']/NRCellCU[@idNRCellCU='\''{{idNRCellCU}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']/sNSSAIList[@sNssai='\''{{sNSSAIList}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nssai-from-cucp-rrmpolicy",
"model": "ran-network",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUCPFunction[@idGNBCUCPFunction='\''{{idGNBCUCPFunction}}'\'']/NRCellCU[@idNRCellCU='\''{{idNRCellCU}}'\'']/attributes/RRMPolicyRatio[@id='\''{{id}}'\'']/attributes/rRMPolicyMemberList[@idx='\''{{idx}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nssai-from-cuup-plmninfo",
"model": "ran-network",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUUPFunction[@idGNBCUUPFunction='\''{{idGNBCUUPFunction}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']/sNSSAIList[@sNssai='\''{{sNSSAIList}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nssai-from-cuup-rrmpolicy",
"model": "ran-network",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUUPFunction[@idGNBCUUPFunction='\''{{idGNBCUUPFunction}}'\'']/attributes/RRMPolicyRatio[@id='\''{{id}}'\'']/attributes/rRMPolicyMemberList[@idx='\''{{idx}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nssai-from-du-plmninfo",
"model": "ran-network",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBDUFunction[@idGNBDUFunction='\''{{idGNBDUFunction}}'\'']/NRCellDU[@idNRCellDU='\''{{idNRCellDU}}'\'']/attributes/pLMNInfoList[@mcc='\''{{mcc}}'\'' and @mnc='\''{{mnc}}'\'']/sNSSAIList[@sNssai='\''{{sNSSAIList}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nssai-from-du-rrmpolicy",
"model": "ran-network",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBDUFunction[@idGNBDUFunction='\''{{idGNBDUFunction}}'\'']/NRCellDU[@idNRCellDU='\''{{idNRCellDU}}'\'']/attributes/RRMPolicyRatio[@id='\''{{id}}'\'']/attributes/rRMPolicyMemberList[@idx='\''{{idx}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nrcellcu-rrmpolicyratio",
"model": "ran-network",
"requestType": "delete",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUCPFunction[@idGNBCUCPFunction='\''{{idGNBCUCPFunction}}'\'']/NRCellCU[@idNRCellCU='\''{{idNRCellCU}}'\'']/attributes/RRMPolicyRatio[@id='\''{{id}}'\'']/attributes"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-cuup-rrmpolicyratio",
"model": "ran-network",
"requestType": "delete",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBCUUPFunction[@idGNBCUUPFunction='\''{{idGNBCUUPFunction}}'\'']/attributes/RRMPolicyRatio[@id='\''{{id}}'\'']/attributes"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-nrcelldu-rrmpolicyratio",
"model": "ran-network",
"requestType": "delete",
"xpathTemplate": "/ran-network/NearRTRIC[@idNearRTRIC='\''{{idNearRTRIC}}'\'']/GNBDUFunction[@idGNBDUFunction='\''{{idGNBDUFunction}}'\'']/NRCellDU[@idNRCellDU='\''{{idNRCellDU}}'\'']/attributes/RRMPolicyRatio[@id='\''{{id}}'\'']/attributes"
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-rannfnssi",
"model": "ran-inventory",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-inventory/ran-slices[@rannfnssiid='\''{{rannfnssiid}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "delete-slice-profile",
"model": "ran-inventory",
"requestType": "delete-list-node",
"xpathTemplate": "/ran-inventory/ran-slices[@rannfnssiid='\''{{rannfnssiid}}'\'']/sliceProfilesList[@sliceProfileId='\''{{sliceProfileId}}'\'']",
"includeDescendants": true
}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header "Content-Type: application/json" \
--data-raw '{
"templateId": "get-ran-slices",
"model": "ran-inventory",
"requestType": "get",
"xpathTemplate": "/ran-inventory/ran-slices[@rannfnssiid='\''{{rannfnssiid}}'\'']",
"includeDescendants": true,
"transformParam":"ran-slices"
}'


