This source repository contains the directed graphs to support the
SDNC controller, as well as the code to create the SDNC docker containers.

# Local compilation

The following command will do a local build and create all SDNC
docker containers:

```bash
mvn clean install -P docker -Ddocker.pull.registry=nexus3.onap.org:10001
```

To do a local build of only the SDNC controller docker image:

```bash
cd installation/sdnc
mvn clean install -P docker -Ddocker.pull.registry=nexus3.onap.org:10001
```

# Local CSIT testing

To perform local CSIT testing, first create a local docker build
of the SDNC controller images following the steps above.  

Important note: CSIT testing is still based on Python2.  So, before
running the CSIT locally, be sure that your local environment is
using the python2 version of 'python' and 'pip'

Once you have a local SDNC image build and python2 is installed,
you can run a local CSIT test by running the following commands:

```bash
cd csit
./run-project-csit.sh
```

