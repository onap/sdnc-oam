if [ "$#" != "1" ]
then
        echo "Usage: $0 xmlFileFullPath"
        exit
fi

if [ -z "$PROJECT_HOME" ]
then
        export PROJECT_HOME=$(pwd)/..
fi
export CLASSPATH=$CLASSPATH:.
if [ -e "$1" ]
then
	java FormatXml $1
else
	echo "File $1 does not exist" 
fi
