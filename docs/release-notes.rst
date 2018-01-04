.. This work is licensed under a Creative Commons Attribution 4.0 International License.

Release Notes
=============

Version: 1.2.1
--------------


:Release Date: 2018-11-16

**Bug Fixes**

   - `SDNC-145 <https://jira.onap.org/browse/SDNC-145>`_ Error message refers to wrong parameters
   - `SDNC-195 <https://jira.onap.org/browse/SDNC-195>`_ UEB listener doesn't insert correct parameters for allotted resources in DB table ALLOTTED_RESOURCE_MODEL
   - `SDNC-198 <https://jira.onap.org/browse/SDNC-198>`_ CSIT job fails
   - `SDNC-201 <https://jira.onap.org/browse/SDNC-201>`_ Fix DG bugs from integration tests
   - `SDNC-202 <https://jira.onap.org/browse/SDNC-202>`_ Search for service -data null match, set vGW LAN IP via Heat
   - `SDNC-211 <https://jira.onap.org/browse/SDNC-211>`_ Update SDNC Amsterdam branch to use maintenance release versions
   - `SDNC-212 <https://jira.onap.org/browse/SDNC-212>`_ Duplicate file name





Version: 1.2.0
--------------


:Release Date: 2018-11-16



**New Features**

The ONAP Amsterdam release introduces the following changes to SDNC from
the original openECOMP seed code:
   - Refactored / moved common platform code to new CCSDK project
   - Refactored code to rename openecomp to onap
   - Introduced new GENERIC-RESOURCE-API api, used by vCPE and VoLTE use cases
   - Introduced new docker containers for SDC and DMAAP interfaces

**Bug Fixes**
**Known Issues**
The following known high priority issues are being worked and are expected to be delivered
in release 1.2.1:
   - `SDNC-179 <https://jira.onap.org/browse/SDNC-179>`_ Failed to make HTTPS connection in restapicall node
   - `SDNC-181 <https://jira.onap.org/browse/SDNC-181>`_ Change call to brg-wan-ip-address vbrg-wan-ip brg topo activate DG
   - `SDNC-182 <https://jira.onap.org/browse/SDNC-182>`_ Fix VNI Consistency: Add vG vxlan tunnel setup and bridge domain setup to brg-topo-activate DG


**Security Issues**
   You may want to include a reference to CVE (Common Vulnerabilities and Exposures) `CVE <https://cve.mitre.org>`_


**Upgrade Notes**

**Deprecation Notes**

**Other**

