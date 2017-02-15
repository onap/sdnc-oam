toolsDir=$PROJECT_HOME/tools
appRootDir=$1
yangFilesDirFullPath=$2
baseYangFile=$3

#echo ${appRootDir} 
#echo ${yangFilesDirFullPath} 
#echo ${baseYangFile} 
if [ "$#" -lt "3" ]
then
	echo "Usage: $0 appRootDir yangFilesDirectoryFullPath baseYangFile  example:$0 asdcApi /home/brocade/sdnc/asdcApi ASDC-API.yang"
	exit
fi
cd ${toolsDir}/tmpws
#cp ${toolsDir}/module-provider-impl.yang ${toolsDir}/tmpws

if [ ! -e "${toolsDir}/module-provider-impl.yang" ]
then
	echo "module-provider-impl.yang should exist in the current directory"
	exit
fi

#echo "appRootDir:$appRootDir"
#echo "yangFileFullPath:$yangFileFullPath"
#echo "yangFile:$yangFile"
cp ${yangFilesDirFullPath}/*.yang ${appRootDir}/model/src/main/yang
if [ "$?" != "0" ]
then
	echo "Could not copy the yang file. Exiting ..."
	exit
fi

moduleName=$(cat ${yangFilesDirFullPath}/${baseYangFile}|egrep "module .*{"|cut -d' ' -f2|cut -d'{' -f1)
sed -i.bak s/\$MODULE/$1/g ${toolsDir}/module-provider-impl.yang
cp ${toolsDir}/module-provider-impl.yang ${appRootDir}/provider/src/main/yang/${appRootDir}-provider-impl.yang 
cd $appRootDir
mvn clean install  >${toolsDir}/tmpws/logs/mvn_install.log 2>&1
if [ "$?" != "0" ]
then
	echo "mvn compile failed"
	exit 1	
fi
mkdir ${toolsDir}/tmpws/jars
cp ./model/target/${appRootDir}.model-1.0.0-SNAPSHOT.jar ${toolsDir}/tmpws/jars

mv ${toolsDir}/output_js/${moduleName}.js ${toolsDir}/output_js/${moduleName}.js_prev >/dev/null  2>&1 
${toolsDir}/getRpcsClassFromYangs.sh ${yangFilesDirFullPath}/${baseYangFile} ${toolsDir}/tmpws/${appRootDir}/model/target/${appRootDir}.model-1.0.0-SNAPSHOT.jar > ${toolsDir}/output_js/${moduleName}.js

mv  ${toolsDir}/output_js/${moduleName}_inputs.js ${toolsDir}/output_js/${moduleName}_inputs_prev.js >/dev/null 2>&1
node ${toolsDir}/dot_to_json.js ${toolsDir}/output_js/${moduleName}.js $moduleName >>${toolsDir}/output_js/${moduleName}_inputs.js
cp ${toolsDir}/output_js/${moduleName}_inputs.js $PROJECT_HOME/generatedJS
