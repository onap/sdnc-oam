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

This document provides the release notes for the Istanbul release of the Software Defined
Network Controller (SDNC)

Summary
=======

The Istanbul release of SDNC includes enhancements network slicing as well as a major OpenDaylight release
upgrade (to Silicon).

The Istanbul release of SDNC also includes substantial improvements in automated test coverage integrated into
the project's CI/CD framework.  In this release, each time a new SDNC is built, a regression suite is run
and the docker is only saved if it passes this regression suite.



Release Data
============

+-------------------------+-------------------------------------------+
| **Project**             | SDNC                                      |
|                         |                                           |
+-------------------------+-------------------------------------------+
| **Docker images**       | See :ref:`dockercontainers` section below |
+-------------------------+-------------------------------------------+
| **Release designation** | Istanbul                                  |
|                         |                                           |
+-------------------------+-------------------------------------------+


New features
------------

The SDNC Istanbul release includes the following features, most of which are inherited from CCSDK:

* Enhance CSIT testing for SDNC (Jira `SDNC-1544 <https://jira.onap.org/browse/SDNC-1544>`)
* Upgrade to OpenDaylight Silicon Release (Jira `CCSDK-3390 <https://jira.onap.org/browse/CCSDK-3390>`_)
* A1 Adapter and A1 Policy Management Extensions in Istanbul Release - CCSDK (Jira `CCSDK-3229 <https://jira.onap.org/browse/CCSDK-3229>`_)
* Support of O-RAN-SC D-Release (Jira `CCSDK-3158 <https://jira.onap.org/browse/CCSDK-3158>`_)
* CCSDK impacts for Network slicing in Istanbul Release (Jira `CCSDK-3297 <https://jira.onap.org/browse/CCSDK-3297>`_)

For the complete list of `SDNC Istanbul release epics <https://jira.onap.org/issues/?filter=12638>`_ and 
`SDNC Honolulu release user stories <https://jira.onap.org/issues/?filter=12637>`_ , please see the `ONAP Jira`_.

**Bug fixes**

The full list of `bugs fixed in the SDNC Istanbul release <https://jira.onap.org/issues/?filter=12643>`_ is maintained on the `ONAP Jira`_.

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
| onap/sdnc-aaf-image            | SDNC controller image, integrated with AAF for RBAC | 2.2.2   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ansible-server-image | Ansible server                                      | 2.2.2   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-dmaap-listener-image | DMaaP listener                                      | 2.2.2   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-image                | SDNC controller image, without AAF integration      | 2.2.2   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ueb-listener-image   | SDC listener                                        | 2.2.2   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-web-image            | Web tier (currently only used by SDN-R persona)     | 2.2.2   |
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

There are no known outstanding security issues related to SDNC Istanbul.


Test Results
============
Not applicable


References
==========

For more information on the ONAP Istanbul release, please see:

#. `ONAP Home Page`_
#. `ONAP Documentation`_
#. `ONAP Release Downloads`_
#. `ONAP Wiki Page`_


.. _`ONAP Home Page`: https://www.onap.org
.. _`ONAP Wiki Page`: https://wiki.onap.org
.. _`ONAP Documentation`: https://docs.onap.org
.. _`ONAP Release Downloads`: https://git.onap.org
.. _`ONAP Jira`: https://jira.onap.org
.. _`SDN Controller for Radio user guide`: https://docs.onap.org/projects/onap-ccsdk-features/en/latest/guides/onap-user/home.html
