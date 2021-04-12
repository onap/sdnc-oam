.. This work is licensed under a Creative Commons Attribution 4.0
   International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) ONAP Project and its contributors
.. _release_notes:

******************
SDNC Release Notes
******************


Abstract
========

This document provides the release notes for the Honolulu release of the Software Defined
Network Controller (SDNC)

Summary
=======

The Honolulu release of SDNC introduces new functionality to support network slicing and extends support
for Netconf/TLS to address certificate management.  It also includes a major OpenDaylight release
upgrade (to Sodium), as well as a major Java upgrade (from Java 8 to Java 11).



Release Data
============

+-------------------------+-------------------------------------------+
| **Project**             | SDNC                                      |
|                         |                                           |
+-------------------------+-------------------------------------------+
| **Docker images**       | See :ref:`dockercontainers` section below |
+-------------------------+-------------------------------------------+
| **Release designation** | Honolulu                                  |
|                         |                                           |
+-------------------------+-------------------------------------------+
| **Release date**        | 11/19/2020                                |
|                         |                                           |
+-------------------------+-------------------------------------------+


New features
------------

The SDNC Honolulu release includes the following features:

* SDN-C (SDN-R) support of E2E Network Slicing in Honolulu (Jira `SDNC-1415 <https://jira.onap.org/browse/SDNC-1415>`_)
* ONAP CNF Orchestration - Honolulu Enhancements (SDNC) (Jira `SDNC-1451 <https://jira.onap.org/browse/SDNC-1451>`_)
* Decouple SDNC from OpenDaylight / Karaf : phase 3 (Jira `SDNC-1348 <https://jira.onap.org/browse/SDNC-1348>`_)

This release also includes an upgrade to the OpenDaylight Aluminum release, which SDNC consumes from CCSDK.

For the complete list of `SDNC Honolulu release epics <https://jira.onap.org/issues/?filter=12498>`_ and 
`SDNC Honolulu release user stories <https://jira.onap.org/issues/?filter=12499>`_ , please see the `ONAP Jira`_.

**Bug fixes**

The full list of `bugs fixed in the SDNC Honolulu release <https://jira.onap.org/issues/?filter=12500>`_ is maintained on the `ONAP Jira`_.

**Known Issues**

The full list of `known issues in SDNC <https://jira.onap.org/issues/?filter=11119>`_ is maintained on the `ONAP Jira`_.



Deliverables
------------

Software Deliverables
~~~~~~~~~~~~~~~~~~~~~

.. _dockercontainers:

Docker Containers
`````````````````

The following table lists the docker containers comprising the SDNC Honolulu
release along with the current stable Honolulu version/tag.  Each of these is
available on the ONAP nexus3 site (https://nexus3.onap.org) and can be downloaded
with the following command::

   docker pull nexus3.onap.org:10001/{image-name}:{version}



+--------------------------------+-----------------------------------------------------+---------+
| Image name                     | Description                                         | Version |
+================================+=====================================================+=========+
| onap/sdnc-aaf-image            | SDNC controller image, integrated with AAF for RBAC | 2.1.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ansible-server-image | Ansible server                                      | 2.1.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-dmaap-listener-image | DMaaP listener                                      | 2.1.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-image                | SDNC controller image, without AAF integration      | 2.1.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ueb-listener-image   | SDC listener                                        | 2.1.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-web-image            | Web tier (currently only used by SDN-R persona)     | 2.1.4   |
+--------------------------------+-----------------------------------------------------+---------+


Documentation Deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~

* `SDN Controller for Radio user guide`_

Known Limitations, Issues and Workarounds
=========================================

System Limitations
------------------

No system limitations noted.


Known Vulnerabilities
---------------------

Any known vulnerabilities for ONAP are tracked in the `ONAP Jira`_ in the OJSI project.  Any outstanding OJSI issues that
pertain to SDNC are listed in the :ref:`secissues` section below.


Workarounds
-----------

Not applicable.


Security Notes
--------------


Known Security Issues
~~~~~~~~~~~~~~~~~~~~~

There are no known outstanding security issues related to SDNC Honolulu.


Test Results
============
Not applicable


References
==========

For more information on the ONAP Honolulu release, please see:

#. `ONAP Home Page`_
#. `ONAP Documentation`_
#. `ONAP Release Downloads`_
#. `ONAP Wiki Page`_


.. _`ONAP Home Page`: https://www.onap.org
.. _`ONAP Wiki Page`: https://wiki.onap.org
.. _`ONAP Documentation`: https://docs.onap.org
.. _`ONAP Release Downloads`: https://git.onap.org
.. _`ONAP Jira`: https://jira.onap.org
.. _`SDN Controller for Radio user guide`: https://docs.onap.org/en/frankfurt/submodules/ccsdk/features.git/docs/guides/onap-user/home.html
