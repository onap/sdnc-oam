#!/bin/sh

OKFILE=${ODL_HOME}/data/log/INSTALLCERTSPASS
NOTOKFILE=${ODL_HOME}/data/log/INSTALLCERTSFAIL
INSTALLCOMPLETE=false
elapsedTime=0

printInstallCertsLog() {
  printf "################ Contents of ${ODL_HOME}/data/log/installCerts.log ################ \n"
  cat ${ODL_HOME}/data/log/installCerts.log
}

while [[ $INSTALLCOMPLETE != true ]]; do
  printf "Certificate installation in progress. Elapsed time - $elapsedTime secs. Waiting for 10 secs before checking the status.. \n"
  sleep 10
  elapsedTime=$((elapsedTime + 10))
  pid=$(pgrep -f installCerts.py)
  if [[ $? != 0 ]]; then
     INSTALLCOMPLETE=true
  fi
done

printf "Certificate installation script completed execution \n"
if [ -f $OKFILE ]; then
  #do nothing
  printf "Everything OK in Certificate Installation \n"
elif [ -f $NOTOKFILE ]; then
  # Terminate SDNR container
  printf "Problems encountered in Certificate Installation \n"
  printInstallCertsLog
  printf "Stoppping SDNR container due to failure in installing Certificates \n"
  pid=`pgrep java`
  kill -SIGKILL $pid
fi

