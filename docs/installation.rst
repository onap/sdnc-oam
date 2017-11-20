.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

Introduction
============
The purpose of this document is to explain how to build an ONAP SDNC Instance on vanilla Openstack deployment.
The document begins with creation of a network, and a VM.
Then, the document explains how to run the installation scripts on the VM.
Finally, the document shows how to check that the SDNC installation was completed successfully.
This document and logs were created on 14 November, 2017.

Infrastructure setup on OpenStack
---------------------------------
Create the network, we call it “ONAP-net”:

::

 cloud@olc-ubuntu2:~$ neutron net-create onap-net
 neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
 Created a new network:
 +-----------------+--------------------------------------+
 | Field           | Value                                |
 +-----------------+--------------------------------------+
 | admin_state_up  | True                                 |
 | id              | 662650f0-d178-4745-b4fe-dd2cb735160c |
 | name            | onap-net                             |
 | router:external | False                                |
 | shared          | False                                |
 | status          | ACTIVE                               |
 | subnets         |                                      |
 | tenant_id       | 324b90de6e9a4ad88e93a100c2cedd5d     |
 +-----------------+--------------------------------------+
 cloud@olc-ubuntu2:~$

Create the subnet, “ONAP-subnet”:

::

 cloud@olc-ubuntu2:~$ neutron subnet-create --name onap-subnet onap-net 10.0.0.0/16
 neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
 Created a new subnet:
 +-------------------+----------------------------------------------+
 | Field             | Value                                        |
 +-------------------+----------------------------------------------+
 | allocation_pools  | {"start": "10.0.0.2", "end": "10.0.255.254"} |
 | cidr              | 10.0.0.0/16                                  |
 | dns_nameservers   |                                              |
 | enable_dhcp       | True                                         |
 | gateway_ip        | 10.0.0.1                                     |
 | host_routes       |                                              |
 | id                | 574df42f-15e9-4761-a4c5-e48d64f04b99         |
 | ip_version        | 4                                            |
 | ipv6_address_mode |                                              |
 | ipv6_ra_mode      |                                              |
 | name              | onap-subnet                                  |
 | network_id        | 662650f0-d178-4745-b4fe-dd2cb735160c         |
 | tenant_id         | 324b90de6e9a4ad88e93a100c2cedd5d             |
 +-------------------+----------------------------------------------+
 cloud@olc-ubuntu2:~$

Boot an Ubuntu 14.04 instance, using the correct flavor name according to your Openstack :

::

 cloud@olc-ubuntu2:~$ nova boot --flavor n2.cw.standard-4 --image "Ubuntu 14.04" --key-name olc-
 key2 --nic net-name=onap-net,v4-fixed-ip=10.0.7.1 vm1-sdnc
 +--------------------------------------+-----------------------------------------------------+
 | Property                             | Value                                               |
 +--------------------------------------+-----------------------------------------------------+
 | OS-DCF:diskConfig                    | MANUAL                                              |
 | OS-EXT-AZ:availability_zone          |                                                     |
 | OS-EXT-STS:power_state               | 0                                                   |
 | OS-EXT-STS:task_state                | scheduling                                          |
 | OS-EXT-STS:vm_state                  | building                                            |
 | OS-SRV-USG:launched_at               | -                                                   |
 | OS-SRV-USG:terminated_at             | -                                                   |
 | accessIPv4                           |                                                     |
 | accessIPv6                           |                                                     |
 | config_drive                         |                                                     |
 | created                              | 2017-11-14T15:48:37Z                                |
 | flavor                               | n2.cw.standard-4 (44)                               |
 | hostId                               |                                                     |
 | id                                   | 596e2b1f-ff09-4c8e-b3e8-fc06566306cf                |
 | image                                | Ubuntu 14.04 (ac9d6735-7c2b-4ff1-90e9-b45225fd80a9) |
 | key_name                             | olc-key2                                            |
 | metadata                             | {}                                                  |
 | name                                 | vm1-sdnc                                            |
 | os-extended-volumes:volumes_attached | []                                                  |
 | progress                             | 0                                                   |
 | security_groups                      | default                                             |
 | status                               | BUILD                                               |
 | tenant_id                            | 324b90de6e9a4ad88e93a100c2cedd5d                    |
 | updated                              | 2017-11-14T15:48:38Z                                |
 | user_id                              | 24c673ecc97f4b42887a195654d6a0b9                    |
 +--------------------------------------+-----------------------------------------------------+
 cloud@olc-ubuntu2:~$

Create a floating IP and associate to the SDNC VM so that it can access internet to download needed files:

::

 cloud@olc-ubuntu2:~$ neutron floatingip-create public
 neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
 Created a new floatingip:
 +---------------------+--------------------------------------+
 | Field               | Value                                |
 +---------------------+--------------------------------------+
 | fixed_ip_address    |                                      |
 | floating_ip_address | 84.39.47.153                         |
 | floating_network_id | b5dd7532-1533-4b9c-8bf9-e66631a9be1d |
 | id                  | eac0124f-9c92-47e5-a694-53355c06c6b2 |
 | port_id             |                                      |
 | router_id           |                                      |
 | status              | ACTIVE                               |
 | tenant_id           | 324b90de6e9a4ad88e93a100c2cedd5d     |
 +---------------------+--------------------------------------+
 cloud@olc-ubuntu2:~$
 cloud@olc-ubuntu2:~$ neutron port-list
 neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
 +--------------------------------------+--------------------------------------+-------------------+-------------------------------------------------------------------------------------+
 | id                                   | name                                 | mac_address       | fixed_ips                                                                           |
 +--------------------------------------+--------------------------------------+-------------------+-------------------------------------------------------------------------------------+
 | 5d8e8f30-a13a-417d-b5b4-f4038224364b | 5d8e8f30-a13a-417d-b5b4-f4038224364b | 02:5d:8e:8f:30:a1 | {"subnet_id": "574df42f-15e9-4761-a4c5-e48d64f04b99", "ip_address": "10.0.7.1"}     |
 +--------------------------------------+--------------------------------------+-------------------+-------------------------------------------------------------------------------------+
 cloud@olc-ubuntu2:~$
 cloud@olc-ubuntu2:~$ neutron floatingip-associate eac0124f-9c92-47e5-a694-53355c06c6b25d8e8f30-a13a-417d-b5b4-f4038224364b
 neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
 Associated floating IP eac0124f-9c92-47e5-a694-53355c06c6b2
 cloud@olc-ubuntu2:~$

Add the security group to the VM in order to open needed ports for SDNC like port 22, 3000, 8282 etc ...:

::

 cloud@olc-ubuntu2:~$ nova add-secgroup vm1-sdnc olc-onap
 cloud@olc-ubuntu2:~$

Installing SDNC
---------------

Connect to the new VM and change to user "root", and run the following commands to start the installation (the full logs are listed in the attached text file):

::

 cloud@vm1-sdnc:~$ sudo -i
 root@vm1-sdnc:~# mkdir -p /opt/config
 root@vm1-sdnc:~#
 root@vm1-sdnc:~# echo "https://nexus.onap.org/content/sites/raw" > /opt/config/nexus_repo.txt
 root@vm1-sdnc:~# echo "nexus3.onap.org:10001" > /opt/config/nexus_docker_repo.txt
 root@vm1-sdnc:~# echo "docker" > /opt/config/nexus_username.txt
 root@vm1-sdnc:~# echo "docker" > /opt/config/nexus_password.txt
 root@vm1-sdnc:~# echo "1.1.0-SNAPSHOT" > /opt/config/artifacts_version.txt
 root@vm1-sdnc:~# echo "10.0.100.1" > /opt/config/dns_ip_addr.txt
 root@vm1-sdnc:~# wget https://git.onap.org/integration/plain/version-manifest/src/main/resources/docker-manifest.csv
 root@vm1-sdnc:~# DOCKER_SDNC_VERSION=$(grep onap/sdnc-image docker-manifest.csv | awk  '{v=$1; gsub(".*/*,","",$1);  print  ($1) }') 
 root@vm1-sdnc:~# echo $DOCKER_SDNC_VERSION > /opt/config/docker_version.txt
 root@vm1-sdnc:~# echo "master" > /opt/config/gerrit_branch.txt
 root@vm1-sdnc:~# echo "openstack" > /opt/config/cloud_env.txt
 root@vm1-sdnc:~# echo "8.8.8.8" > /opt/config/external_dns.txt
 root@vm1-sdnc:~# echo "http://gerrit.onap.org/r/sdnc/oam.git" > /opt/config/remote_repo.txt
 root@vm1-sdnc:~# DOCKER_BUILDER_VERSION=$(grep dgbuilder docker-manifest.csv | awk  '{v=$1; gsub(".*/*,","",$1);  print  ($1) }') 
 root@vm1-sdnc:~# echo $DOCKER_BUILDER_VERSION > /opt/config/dgbuilder_version.txt
 root@vm1-sdnc:~# curl -k https://nexus.onap.org/content/sites/raw/org.onap.demo/boot/1.1.0-
 SNAPSHOT/sdnc_install.sh -o /opt/sdnc_install.sh
   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                  Dload  Upload   Total   Spent    Left  Speed
 100  3701  100  3701    0     0   5196      0 --:--:-- --:--:-- --:--:--  5190
 root@vm1-sdnc:~# cd /opt
 root@vm1-sdnc:/opt# chmod +x sdnc_install.sh
 root@vm1-sdnc:/opt# ./sdnc_install.sh
 cp: cannot stat ‘/home/ubuntu/.ssh/authorized_keys’: No such file or directory
 Get:1 http://security.ubuntu.com trusty-security InRelease [65.9 kB]
 … output truncated …

The following install logs shows the containers are coming up, meaning a successful deployment of the SDNC:

::

 ... truncated output ...
 Status: Downloaded newer image for mysql/mysql-server:5.6
 Creating sdnc_db_container
 Creating sdnc_controller_container
 Creating sdnc_portal_container
 Creating sdnc_dgbuilder_container
 Creating sdnc_dmaaplistener_container
 Creating sdnc_ueblistener_container
 root@vm1-sdnc:/opt#

Check that the containers are up and running:

::

 cloud@vm1-sdnc:~$ sudo docker container list
 CONTAINER ID        IMAGE                                   COMMAND                  CREATED              STATUS                    PORTS                                            NAMES
 30fd20166145        onap/sdnc-dmaap-listener-image:latest   "/opt/onap/sdnc/dm..."   25 minutes ago      Up 25 minutes                                                              sdnc_dmaaplistener_container
 484220f3b38a        onap/sdnc-ueb-listener-image:latest     "/opt/onap/sdnc/ue..."   25 minutes ago      Up 25 minutes                                                              sdnc_ueblistener_container
 674ad3ff7f24        onap/ccsdk-dgbuilder-image:latest       "/bin/bash -c 'cd ..."   25 minutes ago      Up 25 minutes             0.0.0.0:3000->3100/tcp                           sdnc_dgbuilder_container
 d2a915c8e2e5        onap/admportal-sdnc-image:latest        "/bin/bash -c 'cd ..."   25 minutes ago      Up 25 minutes             0.0.0.0:8843->8843/tcp                           sdnc_portal_container
 a65b7fb486e7        onap/sdnc-image:latest                  "/opt/onap/sdnc/bi..."   25 minutes ago      Up 25 minutes             0.0.0.0:8201->8101/tcp, 0.0.0.0:8282->8181/tcp   sdnc_controller_container
 2b9b2f5a79f8        mysql/mysql-server:5.6                  "/entrypoint.sh my..."   25 minutes ago      Up 25 minutes (healthy)   0.0.0.0:32768->3306/tcp                          sdnc_db_container
 cloud@vm1-sdnc:~$

Login into APIDOC Explorer and check that you can see Swagger UI interface with all the APIs:

::

 APIDOC Explorer URL: http://{SDNC-IP}:8282/apidoc/explorer/index.html
 Username: admin
 Password: Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U

Login into DG Builder and check that you can see the GUI:

::

 DG Builder URL: http://dguser:test123@{SDNC-IP}:3000


