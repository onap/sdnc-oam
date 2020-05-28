.. This work is licensed under a Creative Commons Attribution 4.0
   International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) ONAP Project and its contributors

******************
SDNC Release Notes
******************


Abstract
========

This document provides the release notes for the Frankfurt release of the Software Defined
Network Controller (SDNC)

Summary
=======

The Frankfurt release of SDNC introduces new functionality to support PNFs (Physical Network Functions), extends support
for Netconf/TLS to support CMPv2, and adds support for the Multi Domain Optical Network Service use case.


Release Data
============

+-------------------------+-------------------------------------------+
| **Project**             | SDNC                                      |
|                         |                                           |
+-------------------------+-------------------------------------------+
| **Docker images**       | See :ref:`dockercontainers` section below |
+-------------------------+-------------------------------------------+
| **Release designation** | Frankfurt                                 |
|                         |                                           |
+-------------------------+-------------------------------------------+
| **Release date**        | 06/04/2020                                |
|                         |                                           |
+-------------------------+-------------------------------------------+


New features
------------

The SDNC Frankfurt release includes the following features:

* ORAN-compliant A1 adaptor (Jira `SDNC-965 <https://jira.onap.org/browse/SDNC-965>`_)
* Multi-Domain Optical Service (Jira `SDNC-928 <https://jira.onap.org/browse/SDNC-928>`_)
* Python 2 -> Python 3 migration (Jira `SDNC-967 <https://jira.onap.org/browse/SDNC-967>`_)
* Upgrade to new Policy lifecycle API (Jira `SDNC-968 <https://jira.onap.org/browse/SDNC-968>`_)



For the complete list of `SDNC Frankfurt release epics <https://jira.onap.org/issues/?filter=12322>`_ and 
`SDNC Frankfurt release user stories <https://jira.onap.org/issues/?filter=12323>`_ , please see the `ONAP Jira`_.

**Bug fixes**

The full list of `bugs fixed in the SDNC Frankfurt release <https://jira.onap.org/issues/?filter=12324>`_ is maintained on the `ONAP Jira`_.

**Known Issues**

The full list of `known issues in SDNC <https://jira.onap.org/issues/?filter=11119>`_ is maintained on the `ONAP Jira`_.

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
| onap/sdnc-aaf-image            | SDNC controller image, integrated with AAF for RBAC | 1.8.3   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ansible-server-image | Ansible server                                      | 1.8.3   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-dmaap-listener-image | DMaaP listener                                      | 1.8.3   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-image                | SDNC controller image, without AAF integration      | 1.8.3   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-ueb-listener-image   | SDC listener                                        | 1.8.3   |
+--------------------------------+-----------------------------------------------------+---------+
| onap/sdnc-web-image            | Web tier (currently only used by SDN-R persona)     | 1.8.3   |
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

The following security issues have been addressed in the Frankfurt SDNC release:

* `OSJI-34 <https://jira.onap.org/browse/OJSI-34>`_ : Multiple SQL Injection issues in SDNC
* `OSJI-40 <https://jira.onap.org/browse/OJSI-40>`_ : SDNC service allows for arbitrary code execution
* `OSJI-41 <https://jira.onap.org/browse/OJSI-41>`_ : SDNC service allows for arbitrary code execution in sla/dgUpload form (CVE-2019-12132)
* `OSJI-42 <https://jira.onap.org/browse/OJSI-42>`_ : SDNC service allows for arbitrary code execution in sla/printAsXml form (CVE-2019-12123)
* `OSJI-43 <https://jira.onap.org/browse/OJSI-43>`_ : SDNC service allows for arbitrary code execution in sla/printAsGv form (CVE-2019-12113)
* `OSJI-199 <https://jira.onap.org/browse/OJSI-199>`_ : SDNC service allows for arbitrary code execution in sla/upload form (CVE-2019-12112)
* `SDNC-1145 <https://jira.onap.org/browse/SDNC-1145>`_ : Pods still run as root
* `SDNC-970 <https://jira.onap.org/browse/SDNC-970>`_ : Password removal from OOM Helm charts

.. _secissues :

Known Security Issues
~~~~~~~~~~~~~~~~~~~~~

There is currently one known SDNC security issue, related to the SDNC portal

* `OJSI-91 <https://jira.onap.org/browse/OJSI-91>`_ : SDNC exposes unprotected API for user creation

The current implementation of the SDNC portal has a self-subscription model - so anyone can create an account by going to
the setup link.  This is not appropriate for production deployment and will be fixed in a future release.  
The SDNC portal is disabled in the Frankfurt helm charts and we recommend that it NOT be enabled in a production
deployment until this issue is corrected.



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
