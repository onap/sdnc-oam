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

This document provides the release notes for the Kohn release of the Software Defined
Network Controller (SDNC)

Summary
=======

The Kohn release of SDNC includes enhancements network slicing as well as a major OpenDaylight release
upgrade (to Sulfur).



Release Data
============

+-------------------------+-------------------------------------------+
| **Project**             | SDNC                                      |
|                         |                                           |
+-------------------------+-------------------------------------------+
| **Docker images**       | See :ref:`dockercontainers` section below |
+-------------------------+-------------------------------------------+
| **Release designation** | Kohn                                   |
|                         |                                           |
+-------------------------+-------------------------------------------+


New features
------------

The SDNC Kohn release includes the following features,  which are inherited from CCSDK:

* Upgrade to OpenDaylight Sulfur Release (Jira `CCSDK-3673 <https://jira.onap.org/browse/CCSDK-3673>`_)
* CCSDK Enhancements for 5G OOF SON use case in Kohn release (Jira `CCSDK-3644 <https://jira.onap.org/browse/CCSDK-3644>`_)
* A1 Adapter and A1 Policy Managements Enhancements in Kohn Release - CCSDK (Jira `CCSDK-3617 <https://jira.onap.org/browse/CCSDK-3617>`_)
* Prepare for removal of Bierman RESTCONF in ODL Chlorine release (Jira `CCSDK-3674 <https://jira.onap.org/browse/CCSDK-3674>`_)


For the complete list of `CCSDK Kohn release epics <https://jira.onap.org/issues/?filter=12916>`_ and
`CCSDK Kohn release user stories <https://jira.onap.org/issues/?filter=12917>`_ , please see the `ONAP Jira`_.

**Bug fixes**


The full list of `bugs fixed in the SDNC Kohn release <https://jira.onap.org/issues/?filter=13004>`_ is maintained on the `ONAP Jira`_.

**Known Issues**

The full list of `known issues in SDNC <https://jira.onap.org/issues/?filter=11119>`_ is maintained on the `ONAP Jira`_.



Deliverables
------------

Software Deliverables
~~~~~~~~~~~~~~~~~~~~~

.. _dockercontainers:

Docker Containers
`````````````````

The following table lists the docker containers comprising the SDNC Kohn
release along with the current stable Kohn version/tag.  Each of these is
available on the ONAP nexus3 site (https://nexus3.onap.org) and can be downloaded
with the following command::

   docker pull nexus3.onap.org:10001/{image-name}:{version}



+--------------------------------+-----------------------------------------------------+---------+
| Image name                     | Description                                         | Version |
+================================+=====================================================+=========+
| onap/sdnc-aaf-image            | SDNC controller image, integrated with AAF for RBAC | 2.4.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ansible-server-image | Ansible server                                      | 2.4.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-dmaap-listener-image | DMaaP listener                                      | 2.4.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-image                | SDNC controller image, without AAF integration      | 2.4.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ueb-listener-image   | SDC listener                                        | 2.4.0   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-web-image            | Web tier (currently only used by SDN-R persona)     | 2.4.0   |
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

There are no known outstanding security issues related to SDNC Kohn.


Test Results
============
Not applicable


References
==========

For more information on the ONAP Kohn release, please see:

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
