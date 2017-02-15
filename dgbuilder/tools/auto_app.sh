toolsDir=$PROJECT_HOME/tools
if [ "$#" != "1" ]
then
	echo "Usage: $0 appName"
	exit
fi
appName="$1"
mkdir tmpws
cd tmpws
mkdir logs
mvn archetype:generate -DarchetypeGroupId=com.brocade.developer -DarchetypeArtifactId=brocade.dev.plugin.ext.archetype -DarchetypeVersion=1.2.0.100-SNAPSHOT >${toolsDir}/tmpws/logs/mvn_gen_archetype.log  2>&1  <<EOF
org.openecomp.sdnc.app
${appName}
1.0.0-SNAPSHOT
org.openecomp.sdnc.app
Y
EOF
if [ "$?" == "0" ]
then
	echo "App created successfully"
else
	echo "App creation failed"
fi
${toolsDir}/update_app_impl_yang.sh "${appName}" $1
