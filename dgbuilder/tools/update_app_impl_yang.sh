toolsDir=$PROJECT_HOME/tools
appRootDir=$1
yangFileFullPath=$2
yangFile=$(basename $yangFileFullPath)

if [ "$#" != "2" ]
then
	echo "Usage: $0 appRootDir yangModuleName example:$0 bwcal bwcal"
	exit
fi
cd ${toolsDir}/tmpws
#cp ${toolsDir}/module-provider-impl.yang ${toolsDir}/tmpws

if [ ! -e "${toolsDir}/module-provider-impl.yang" ]
then
	echo "${toolsDir}/module-provider-impl.yang should exist"
	exit
fi

#echo "appRootDir:$appRootDir"
#echo "yangFileFullPath:$yangFileFullPath"
#echo "yangFile:$yangFile"

cp ${yangFileFullPath} ${appRootDir}/model/src/main/yang/${yangFile}
if [ "$?" != "0" ]
then
	echo "Could not copy the yang file. Exiting ..."
	exit
fi

moduleName=$(cat $yangFileFullPath|egrep "module .*{"|cut -d' ' -f2|cut -d'{' -f1)
#echo $moduleName
sed -i.bak s/\$MODULE/$1/g ${toolsDir}/module-provider-impl.yang
cp ${toolsDir}/module-provider-impl.yang ${appRootDir}/provider/src/main/yang/${appRootDir}-provider-impl.yang 
cd $appRootDir
mvn clean install  >${toolsDir}/tmpws/logs/mvn_install.log 2>&1
mkdir ${toolsDir}/tmpws/jars
cp ./model/target/${appRootDir}.model-1.0.0-SNAPSHOT.jar ${toolsDir}/tmpws/jars

mv  ${toolsDir}/output_js/${moduleName}_inputs.js ${toolsDir}/output_js/${moduleName}_inputs_prev.js >/dev/null 2>&1

${toolsDir}/getRpcsClassFromYang.sh ${yangFileFullPath} ${toolsDir}/tmpws/${appRootDir}/model/target/${appRootDir}.model-1.0.0-SNAPSHOT.jar > ${toolsDir}/output_js/${moduleName}.js

node ${toolsDir}/dot_to_json.js ${toolsDir}/output_js/${moduleName}.js $moduleName >${toolsDir}/output_js/${moduleName}_inputs.js
cp ${toolsDir}/output_js/${moduleName}_inputs.js $PROJECT_HOME/generatedJS
