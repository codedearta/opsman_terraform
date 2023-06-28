#!/bin/bash

function installMongoDbEnterprise()
{
    echo "----  installMongoDbEnterprise ----"
    # install MongoDB enterprise
    sudo mv /tmp/mongodb-enterprise.repo /etc/yum.repos.d/mongodb-enterprise.repo

    # sudo yum update -y
    sudo yum install -y mongodb-enterprise
}

function copyMongodConf()
{
    echo "----  copyMongodConf ----"
    sudo cp /tmp/mongod.conf.orig /etc/mongod.conf
}

function createMongodBackupUnitFile()
{
    echo "----  createMongodBackupUnitFile ----"
    # create mongod_backup unit file
    cat /usr/lib/systemd/system/mongod.service \
    | sed "s/mongod.conf/mongod_backup.conf/g" \
    | sed "s/mongod.pid/mongod_backup.pid/g" \
    > /tmp/mongod_backup.service
    sudo cp /tmp/mongod_backup.service /usr/lib/systemd/system/mongod_backup.service
}

function mongodBackupConfFile()
{
    echo "----  mongodBackupConfFile ----"
    # create mongod_backup.conf file
    sudo mkdir -p /var/lib/mongo_backup
    sudo chown -R mongod:mongod /var/lib/mongo_backup
    sudo chmod -R 0755 /var/lib/mongo_backup

    sudo mkdir -p /var/log/mongodb_backup
    sudo chown -R mongod:mongod /var/log/mongodb_backup
    sudo chmod -R 0755 /var/log/mongodb_backup

    cat /tmp/mongod.conf.orig \
    | sed "s/27017/27018/g" \
    | sed "s,dbPath: /var/lib/mongo,dbPath: /var/lib/mongo_backup,g" \
    | sed "s,path: /var/log/mongodb,path: /var/log/mongodb_backup,g" \
    | sed "s/mongod.pid/mongod_backup.pid/g" \
    | sed "s/appDb/backupDb/g" \
    > /tmp/mongod_backup.conf
    sudo cp /tmp/mongod_backup.conf /etc/mongod_backup.conf
}

function installOpsManager()
{
    echo "----  installOpsManager ----"
    # install OpsManager
    curl -O https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-6.0.15.100.20230614T1851Z.x86_64.rpm
    sudo rpm -ivh mongodb-mms-6.0.15.100.20230614T1851Z.x86_64.rpm
}

function createHeadDbFolder()
{
    echo "----  createHeadDbFolder ----"
    sudo rm -rf /headDBs
    sudo mkdir -p /headDBs
    sudo chown -R mongodb-mms:mongodb-mms /headDBs
    sudo chmod -R 700 /headDBs
}

function copyGenKey()
{
    echo "----  copyGenKey ----"
    sudo cp /tmp/gen.key /etc/mongodb-mms/gen.key
    sudo chown -R mongodb-mms:mongodb-mms /etc/mongodb-mms/
    sudo chmod 400 /etc/mongodb-mms/gen.key
}

function copyKeyfile()
{
    echo "----  copyKeyfile ----"
    sudo cp /tmp/keyfile /var/lib/mongo/keyfile
    sudo chown mongod:mongod /var/lib/mongo/keyfile
    sudo chmod 400 /var/lib/mongo/keyfile
}

function startBackingDbs()
{
    echo "----  startBackingDbs ----"
    # start MongoDB enterprise AppDB
    sudo systemctl start mongod
    sudo systemctl enable mongod

    # start MongoDB enterprise BackupDB
    sudo systemctl start mongod_backup
    sudo systemctl enable mongod_backup
}

installMongoDbEnterprise
copyMongodConf
createMongodBackupUnitFile
mongodBackupConfFile
installOpsManager
createHeadDbFolder
copyGenKey
copyKeyfile
startBackingDbs
