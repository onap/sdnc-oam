#!/bin/bash

#ran-simulator
git clone https://gerrit.onap.org/r/integration/simulators/ran-simulator

JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ mvn -f ran-simulator/ransim clean install -P docker
cp properties/ran-simulator/docker-compose.yml ran-simulator/ransim/docker/

docker-compose -f ran-simulator/ransim/docker/docker-compose.yml up -d
sleep 20

#starting simulation
curl -k --request POST \
--header 'Content-Type: application/json' \
--header 'Accept: */*' 'http://localhost:8081/ransim/api/StartRanSliceSimulation'


#honeycomb
git clone https://github.com/onap-oof-pci-poc/ran-sim

JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ mvn -f ran-sim/hcsim-content/gnbsim clean install -Dcheckstyle.skip

cp ran-sim/hcsim-content/gnbsim/gnbsim-distribution/Dockerfile ran-sim/hcsim-content/gnbsim/gnbsim-distribution/target/gnbsim-distribution-1.19.08-SNAPSHOT-hc/gnbsim-distribution-1.19.08-SNAPSHOT/

docker build -t gn:latest ran-sim/hcsim-content/gnbsim/gnbsim-distribution/target/gnbsim-distribution-1.19.08-SNAPSHOT-hc/gnbsim-distribution-1.19.08-SNAPSHOT/

cp properties/ran-sim/gnbsim.json ran-sim/hcsim-content/gnbsim/honeycomb/hc/config/
cp properties/ran-sim/docker-compose.yml ran-sim/hcsim-content/gnbsim/honeycomb/hc/


docker-compose -f ran-sim/hcsim-content/gnbsim/honeycomb/hc/docker-compose.yml up -d

sleep 10

#mounting honeycomb with sdnr
curl -i -X PUT http://localhost:8181/restconf/config/network-topology:network-topology/topology/topology-netconf/node/11 -k\
  -H 'Accept: application/xml' -H 'Content-Type: text/xml' \
  --user "admin":"Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U" \
  -d '<node xmlns="urn:TBD:params:xml:ns:yang:network-topology">
  <node-id>11</node-id>
  <host xmlns="urn:opendaylight:netconf-node-topology">10.31.4.15</host>
  <port xmlns="urn:opendaylight:netconf-node-topology">2850</port>
  <username xmlns="urn:opendaylight:netconf-node-topology">admin</username>
  <password xmlns="urn:opendaylight:netconf-node-topology">admin</password>
  <tcp-only xmlns="urn:opendaylight:netconf-node-topology">false</tcp-only>
  <!-- non-mandatory fields with default values, you can safely remove these if you do not wish to override any of these values-->
  <reconnect-on-changed-schema xmlns="urn:opendaylight:netconf-node-topology">false</reconnect-on-changed-schema>
  <connection-timeout-millis xmlns="urn:opendaylight:netconf-node-topology">20000</connection-timeout-millis>
  <max-connection-attempts xmlns="urn:opendaylight:netconf-node-topology">0</max-connection-attempts>
  <between-attempts-timeout-millis xmlns="urn:opendaylight:netconf-node-topology">2000</between-attempts-timeout-millis>
  <sleep-factor xmlns="urn:opendaylight:netconf-node-topology">1.5</sleep-factor>
  <!-- keepalive-delay set to 0 turns off keepalives-->
  <keepalive-delay xmlns="urn:opendaylight:netconf-node-topology">120</keepalive-delay>
</node>'


sleep 10
sudo rm -r ran-sim/
sudo rm -r ran-simulator/
