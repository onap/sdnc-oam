#!/bin/bash
#echo "PROJECT_HOME:$PROJECT_HOME"

MYSQL_JDBC_DRIVER=${MYSQL_JDBC_DRIVER:-$PROJECT_HOME/svclogic/lib/mariadb-java-client-2.1.1.jar}
JARDIR="$PROJECT_HOME/svclogic/lib"
#JARDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CLASSPATH=$CLASSPATH:$MYSQL_JDBC_DRIVER
for jar in $JARDIR/*.jar
do
    CLASSPATH=$CLASSPATH:${jar}
done
#echo "CLASSPATH is ${CLASSPATH}"
java  -cp ${CLASSPATH}:${MYSQL_JDBC_DRIVER}:${SLI_COMMON_JAR} org.onap.ccsdk.sli.core.sli.SvcLogicParser $*
