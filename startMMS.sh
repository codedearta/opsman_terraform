#!/bin/bash

function startOpsManager()
{
  echo "----  startOpsManager ----"
  sudo systemctl start mongodb-mms
  sudo systemctl enable mongodb-mms
}

startOpsManager

echo "DONE"