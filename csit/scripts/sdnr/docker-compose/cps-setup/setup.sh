#!/bin/bash

Building cps-tbdmt image
git clone "https://gerrit.onap.org/r/cps/cps-tbdmt"
mvn -f cps-tbdmt/ -Dmaven.test.skip clean install 
sudo rm -r cps-tbdmt/

#Creating containers for cps, cps-tbdmt & aai-resources
docker-compose up -d

sleep 50

#uploading initial cps & cps-tbdmt data
sh data.sh


