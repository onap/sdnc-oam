#! /bin/bash

updateFile() {
sed  -i .orig -e '
s/\(xmlns=.\)http:\/\/www\.onap\.org\/sdnctl\/svclogic/\1http:\/\/www\.onap\.org\/sdnc\/svclogic/g
s/\(xsi:schemaLocation=.\)http:\/\/www\.openecomp\.org\/sdnctl\/svclogic/\1http:\/\/www\.onap\.org\/sdnc\/svclogic/g
' $1
}

for file in $@
do
	updateFile $file
done
