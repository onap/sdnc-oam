#!/bin/bash

CPS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdnr-cps )
echo $CPS_IP
CPS_TBDMT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdnr-cps-tbdmt )
echo $CPS_TBDMT_IP

#CPS data
echo "Creating dataspace: "
curl --location --user cpsuser:cpsr0cks! -H "Accept: application/json" -H "Content-Type: application/json" \
--request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces?dataspace-name=E2EDemo

#######################################################################################################################

echo "\nCreating schema set: "
curl --location --user cpsuser:cpsr0cks! \
--request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/schema-sets --form 'file=@"schema-sets/cps-cavsta-onap-internal@2021-01-28.yang"' --form 'schema-set-name="ran-coverage-area"'

curl --location --user cpsuser:cpsr0cks! \
--request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/schema-sets --form 'file=@"schema-sets/ran-network.zip"' --form 'schema-set-name="ran-network"'

curl --location --user cpsuser:cpsr0cks! \
--request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/schema-sets --form 'file=@"schema-sets/cps-ran-inventory-v2.zip"' --form 'schema-set-name="ran-inventory"'

#########################################################################################################################

echo "\nCreating anchor: "
curl --location --user cpsuser:cpsr0cks!  --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors?schema-set-name=ran-coverage-area \
-d anchor-name=coverage-area-onap

curl --location --user cpsuser:cpsr0cks!  --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors?schema-set-name=ran-network \
-d anchor-name=ran-network-anchor

curl --location --user cpsuser:cpsr0cks!  --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors?schema-set-name=ran-inventory \
-d anchor-name=ran-inventory-anchor

##########################################################################################################################

echo "\nUploading cps payload "
curl --location --user cpsuser:cpsr0cks! --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors/coverage-area-onap/nodes \
--header 'Content-Type: application/json' \
-d @cps-data/cavstareq.json

curl --location --user cpsuser:cpsr0cks! --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors/ran-network-anchor/nodes \
--header 'Content-Type: application/json' \
-d @cps-data/payload-ran-network.json


#curl --location --user cpsuser:cpsr0cks! --request POST \
#http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors/ran-inventory-anchor/nodes \
#--header 'Content-Type: application/json' \
#-d @cps-data/payload-ran-inventory.json
curl --location --user cpsuser:cpsr0cks! --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors/ran-inventory-anchor/nodes \
--header 'Content-Type: application/json' \
--data-raw '{
"ran-inventory":{
}
}'

#CPS-tbdmt data
echo "\nuploading tbdmt-templates"
sh tbdmt-templates/reconfigure-tbdmt-templates.sh
sh tbdmt-templates/activate-tbdmt-templates.sh
sh tbdmt-templates/allocate-tbdmt-templates.sh
sh tbdmt-templates/terminate-tbdmt-templates.sh


