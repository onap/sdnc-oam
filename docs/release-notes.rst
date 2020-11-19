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

This document provides the release notes for the Guilin release of the Software Defined
Network Controller (SDNC)

Summary
=======

The Guilin release of SDNC introduces new functionality to support network slicing and extends support
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
| **Release designation** | Guilin                                    |
|                         |                                           |
+-------------------------+-------------------------------------------+
| **Release date**        | 11/19/2020                                |
|                         |                                           |
+-------------------------+-------------------------------------------+


New features
------------

The SDNC Guilin release includes the following features:

* Upgrade to Java 11 (Jira `SDNC-1242 <https://jira.onap.org/browse/SDNC-1242>`_)
* Network slicing (Jira `SDNC-915 <https://jira.onap.org/browse/SDNC-915>`_)
* NETCONF/TLS Certificate Management (Jira `SDNC-966 <https://jira.onap.org/browse/SDNC-966>`_)
* Decouple SDNC from OpenDaylight / Karaf : phase 2 (Jira `SDNC-1207 <https://jira.onap.org/browse/SDNC-1207>`_)

This release also includes an upgrade to the OpenDaylight Sodium release, which SDNC consumes from CCSDK.
Downstream projects that are consuming SDNC maven artifacts, or that plan to ingest SDNC as source and do local compiles should be
aware that the upgrades to OpenDaylight Sodium and to Java 11 are both potentially breaking changes.  Therefore, we consider
Guilin to be a  major release and have reflected this in our version numbering.

For the complete list of `SDNC Guilin release epics <https://jira.onap.org/issues/?filter=12464>`_ and 
`SDNC Guilin release user stories <https://jira.onap.org/issues/?filter=12465>`_ , please see the `ONAP Jira`_.

**Bug fixes**

The full list of `bugs fixed in the SDNC Guilin release <https://jira.onap.org/issues/?filter=12466>`_ is maintained on the `ONAP Jira`_.

**Known Issues**

The full list of `known issues in SDNC <https://jira.onap.org/issues/?filter=11119>`_ is maintained on the `ONAP Jira`_.


Removed Features
-------------------

**SDNC portal**

The SDNC portal was deprecated in the Frankfurt release, due
to resource contraints.  This functionality was delivered dormant
in Frankfurt (i.e. it is disabled in the Frankfurt helm charts) and was
removed entirely in the Guilin release.

**VNF-API**

The functionality provided by the VNF-API is now provided as part
of the GENERIC-RESOURCE-API.  Therefore, the VNF-API was deprecated
in Frankfurt and has been removed in Guilin.


Deliverables
------------

Software Deliverables
~~~~~~~~~~~~~~~~~~~~~

.. _dockercontainers:

Docker Containers
`````````````````

The following table lists the docker containers comprising the SDNC Frankfurt 
release along with the current stable Frankfurt version/tag.  Each of these is
available on the ONAP nexus3 site (https://nexus3.onap.org) and can be downloaded
with the following command::

   docker pull nexus3.onap.org:10001/{image-name}:{version}


Note: users that want to use the latest in-development Frankfurt version may use the
tag 0.7-STAGING-latest to pull the latest daily Frankfurt build

+--------------------------------+-----------------------------------------------------+---------+
| Image name                     | Description                                         | Version |
+================================+=====================================================+=========+
| onap/sdnc-aaf-image            | SDNC controller image, integrated with AAF for RBAC | 2.0.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ansible-server-image | Ansible server                                      | 2.0.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-dmaap-listener-image | DMaaP listener                                      | 2.0.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-image                | SDNC controller image, without AAF integration      | 2.0.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ueb-listener-image   | SDC listener                                        | 2.0.4   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-web-image            | Web tier (currently only used by SDN-R persona)     | 2.0.4   |
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

Fixed Security Issues
~~~~~~~~~~~~~~~~~~~~~

The following security issue, related to the SDNC portal, is no longer applicable due to removal
of the SDNC portal:

* `OJSI-91 <https://jira.onap.org/browse/OJSI-91>`_ : SDNC exposes unprotected API for user creation

.. _secissues :

Known Security Issues
~~~~~~~~~~~~~~~~~~~~~

There are no known outstanding security issues related to SDNC Guilin.


Test Results
============
Not applicable


References
==========

For more information on the ONAP Frankfurt release, please see:

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
