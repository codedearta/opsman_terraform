#!/bin/bash

function setPrivateDnsNames()
{
  echo "----  setPrivateDnsNames ----"
  source /tmp/export_private_dns_names.sh
}

function initBackinDbReplSets()
{
  echo "---- initBackinDbReplSets ----"
  if [ "$HOSTNAME" = "$opsman0" ]
  then
      mongo --port 27017 --eval "rsName='appDb';port=27017;opsman0='$opsman0';opsman1='$opsman1';opsman2='$opsman2'; " /tmp/initReplSet.js
      mongo --port 27018 --eval "rsName='backupDb';port=27018;opsman0='$opsman0';opsman1='$opsman1';opsman2='$opsman2'; " /tmp/initReplSet.js
  fi
}

function changeMmsConf()
{
  echo "---- changeMmsConf ----"
  cat /opt/mongodb/mms/conf/conf-mms.properties \
  | sed "s;127.0.0.1:27017;opsman:supersecret1.@${opsman0},${opsman1},${opsman2};g" \
  > /tmp/conf-mms.properties
  sudo cp /tmp/conf-mms.properties /opt/mongodb/mms/conf/conf-mms.properties
}

setPrivateDnsNames
initBackinDbReplSets
changeMmsConf

echo "DONE"