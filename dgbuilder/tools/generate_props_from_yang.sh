if [ -z "$PROJECT_HOME" ] 
then
	export PROJECT_HOME=$(pwd)/..
fi

toolsDir=$PROJECT_HOME/tools
rm -rf ${toolsDir}/tmpws 
mkdir ${toolsDir}/tmpws
mkdir ${toolsDir}/tmpws/logs
if [ "$#" != "1" ]
then
	echo "Command line:$0 $*" >${toolsDir}/tmpws/logs/err.log
	echo "Usage: $0 yangFile" >>${toolsDir}/tmpws/logs/err.log
	exit
fi

appName="yangApp"
cd ${toolsDir}/tmpws
mvn archetype:generate -DarchetypeGroupId=com.brocade.developer -DarchetypeArtifactId=brocade.dev.plugin.ext.archetype -DarchetypeVersion=1.2.0.100-SNAPSHOT >${toolsDir}/tmpws/logs/mvn_gen_archetype.log   2>&1  <<EOF
org.openecomp.sdnc.app
${appName}
1.0.0-SNAPSHOT
org.openecomp.sdnc.app
Y
EOF
${toolsDir}/update_app_impl_yang.sh "${appName}" $1
echo "Done..."

