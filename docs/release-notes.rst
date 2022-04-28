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

This document provides the release notes for the Jakarta release of the Software Defined
Network Controller (SDNC)

Summary
=======

The Jakarta release of SDNC includes enhancements network slicing as well as a major OpenDaylight release
upgrade (to Phosphorus).

The Jakarta release of SDNC also includes substantial improvements in automated test coverage integrated into
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
| **Release designation** | Jakarta                                   |
|                         |                                           |
+-------------------------+-------------------------------------------+


New features
------------

The SDNC Jakarta release includes the following features,  which are inherited from CCSDK:

* Upgrade to OpenDaylight Silicon Release (Jira `CCSDK-3390 <https://jira.onap.org/browse/CCSDK-3390>`_)
* A1 Adapter and A1 Policy Management Extensions in Istanbul Release - CCSDK (Jira `CCSDK-3229 <https://jira.onap.org/browse/CCSDK-3229>`_)
* Support of O-RAN-SC D-Release (Jira `CCSDK-3158 <https://jira.onap.org/browse/CCSDK-3158>`_)
* CCSDK impacts for Network slicing in Istanbul Release (Jira `CCSDK-3297 <https://jira.onap.org/browse/CCSDK-3297>`_)


For the complete list of `CCSDK Istanbul release epics <https://jira.onap.org/issues/?filter=12635>`_ and
`CCSDK Istanbul release user stories <https://jira.onap.org/issues/?filter=12636>`_ , please see the `ONAP Jira`_.

**Bug fixes**

The SDNC Jakarta release carries forward a fix from the Istanbul Maintenance Release 1 for a critical vulnerability discovered in log4j by
upgrading to version 2.17.1 of the log4j-core package.  It also removes the 'data-migrator' package, which
was an old Proof of Concept that is no longer maintained and which was using a vulnerable version of log4j.
These changes are described further in Jira `SDNC-1655 <https://jira.onap.org/browse/SDNC-1655>` 

The full list of `bugs fixed in the SDNC Jakarta release <https://jira.onap.org/issues/?filter=12802>`_ is maintained on the `ONAP Jira`_.

**Known Issues**

The full list of `known issues in SDNC <https://jira.onap.org/issues/?filter=11119>`_ is maintained on the `ONAP Jira`_.



Deliverables
------------

Software Deliverables
~~~~~~~~~~~~~~~~~~~~~

.. _dockercontainers:

Docker Containers
`````````````````

The following table lists the docker containers comprising the SDNC Jakarta
release along with the current stable Jakarta version/tag.  Each of these is
available on the ONAP nexus3 site (https://nexus3.onap.org) and can be downloaded
with the following command::

   docker pull nexus3.onap.org:10001/{image-name}:{version}



+--------------------------------+-----------------------------------------------------+---------+
| Image name                     | Description                                         | Version |
+================================+=====================================================+=========+
| onap/sdnc-aaf-image            | SDNC controller image, integrated with AAF for RBAC | 2.3.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ansible-server-image | Ansible server                                      | 2.3.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-dmaap-listener-image | DMaaP listener                                      | 2.3.0  |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-image                | SDNC controller image, without AAF integration      | 2.3.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ueb-listener-image   | SDC listener                                        | 2.3.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-web-image            | Web tier (currently only used by SDN-R persona)     | 2.3.0   |
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
