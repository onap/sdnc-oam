if [ "$PROJECT_HOME" == "" ]
then
	export PROJECT_HOME=$(pwd)/..
fi

toolsDir=$PROJECT_HOME/tools
if [ "$#" != "1" ]
then
	echo "Usage: $0 yangFilesZipFullPath"
	exit
fi
yangFilesZipFullPath="$1"
rm -rf $PROJECT_HOME/tools/tmp
mkdir $PROJECT_HOME/tools/tmp
mv ${yangFilesZipFullPath} $PROJECT_HOME/tools/tmp
cd $PROJECT_HOME/tools/tmp
zipFile=$(basename $yangFilesZipFullPath)
unzip $PROJECT_HOME/tools/tmp/$zipFile
rm ${zipFile}
for i in $(ls *.yang)
do
	fName="$i"
	extension="${fName##*.}"
        moduleName="${fName%.*}"	
 	count=$(grep -w "import $moduleName" *.yang|wc -l)
 	if [ "$count" -eq "0" ]
 	then
		rm -rf $PROJECT_HOME/yangFiles/$moduleName
		mkdir $PROJECT_HOME/yangFiles/$moduleName
		mv *.yang $PROJECT_HOME/yangFiles/$moduleName
		cd $PROJECT_HOME/tools
		echo ./generate_props_from_yangs.sh "$PROJECT_HOME/yangFiles/$moduleName" "$fName"
		./generate_props_from_yangs.sh "$PROJECT_HOME/yangFiles/$moduleName" "$fName"
		exit
 	fi	
done
