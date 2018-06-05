.. This work is licensed under a Creative Commons Attribution 4.0 International License.

Release Notes
=============


Version: 1.3.4


:Release Date: 2018-07-06

**New Features**

The full list of SDNC Beijing Epics and user stories can be found in the ONAP Jira at <https://jira.onap.org/issues/?filter=10791>.  The
following table lists the major features included in the Beijing release.

+-------------+-------------------------------------------------------------------------------------------------------------------------+
| Jira #      |  Abstract                                                                                                               |
+=============+=========================================================================================================================+
|  [SDNC-278] |  Change management in-place software upgrade execution using Ansible <https://jira.onap.org/browse/SDNC-278>            |
+-------------+-------------------------------------------------------------------------------------------------------------------------+
|  [SDNC-163] | Deploy a SDN-C high availability environment - Kubernetes <https://jira.onap.org/browse/SDNC-163>                       |
+-------------+-------------------------------------------------------------------------------------------------------------------------+

**Bug Fixes**

The list of bugs fixed in the SDNC Beijing release may be found in the ONAP Jira at <https://jira.onap.org/issues/?filter=11118>


**Known Issues**

+------------+----------------------------------------------------------------------------------------------------------------------------------+
| Jira #     | Abstract                                                                                                                         |
+============+==================================================================================================================================+
| [SDNC-324] | IPV4_ADDRESS_POOL is empty <https://jira.onap.org/browse/SDNC-324>                                                               |
+------------+----------------------------------------------------------------------------------------------------------------------------------+
| [SDNC-321] | dgbuilder won't save DG <https://jira.onap.org/browse/SDNC-321>                                                                  |
+------------+----------------------------------------------------------------------------------------------------------------------------------+
| [SDNC-304] | SDNC OOM intermittent Healthcheck failure - JSONDecodeError - on different startup order <https://jira.onap.org/browse/SDNC-304> |
+------------+----------------------------------------------------------------------------------------------------------------------------------+
| [SDNC-115] | VNFAPI DGs contain plugin references to software not part of ONAP <https://jira.onap.org/browse/SDNC-115>                        |
+------------+----------------------------------------------------------------------------------------------------------------------------------+
| [SDNC-114] | Generic API DGs contain plugin references to software not part of ONAP <https://jira.onap.org/browse/SDNC-114>                   |
+------------+----------------------------------------------------------------------------------------------------------------------------------+
| [SDNC-106] | VNFAPI DGs contain old openecomp and com.att based plugin references <https://jira.onap.org/browse/SDNC-106>                     |
+------------+----------------------------------------------------------------------------------------------------------------------------------+
| [SDNC-64]  | SDNC is not setting FromApp identifier in logging MDC <https://jira.onap.org/browse/SDNC-64>                                     |
+------------+----------------------------------------------------------------------------------------------------------------------------------+

**Security Notes**

SDNC code has been formally scanned during build time using NexusIQ and all Critical vulnerabilities have been addressed, items that remain open have been assessed for risk and determined to be false positive. The SDNC open Critical security vulnerabilities and their risk assessment have been documented as part of the `project <https://wiki.onap.org/pages/viewpage.action?pageId=28379582>`_.

Quick Links:

- `SDNC project page <https://wiki.onap.org/display/DW/Software+Defined+Network+Controller+Project>`_
- `Passing Badge information for SDNC <https://bestpractices.coreinfrastructure.org/en/projects/1703>`_
- `Project Vulnerability Review Table for SDNC <https://wiki.onap.org/pages/viewpage.action?pageId=28379582>`_

**Upgrade Notes**
	NA

**Deprecation Notes**
	NA

**Other**
	NA

Version: 1.2.1
--------------

:Release Date: 2018-01-18

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

:Release Date: 2017-11-16

**New Features**

The ONAP Amsterdam release introduces the following changes to SDNC from
the original openECOMP seed code:
   - Refactored / moved common platform code to new CCSDK project
   - Refactored code to rename openecomp to onap
   - Introduced new GENERIC-RESOURCE-API api, used by vCPE and VoLTE use cases
   - Introduced new docker containers for SDC and DMAAP interfaces

**Bug Fixes**
	NA
**Known Issues**
The following known high priority issues are being worked and are expected to be delivered
in release 1.2.1:
- `SDNC-179 <https://jira.onap.org/browse/SDNC-179>`_ Failed to make HTTPS connection in restapicall node
- `SDNC-181 <https://jira.onap.org/browse/SDNC-181>`_ Change call to brg-wan-ip-address vbrg-wan-ip brg topo activate DG
- `SDNC-182 <https://jira.onap.org/browse/SDNC-182>`_ Fix VNI Consistency: Add vG vxlan tunnel setup and bridge domain setup to brg-topo-activate DG

**Security Issues**
	NA

**Upgrade Notes**
	NA

**Deprecation Notes**
	NA

**Other**
	NA


