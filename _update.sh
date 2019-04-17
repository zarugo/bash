#!/bin/bash
#set -x
WORKDIR=/home/root
TYPE=$(ps | grep [J]PSApplication | awk '{print $6}')

# clean_scripts(){
# 	rm /home/root/JPSApps/JPSApplication/*AppRun.sh
#
# }

#double check we are in the correct directory
if [ $(pwd) != $WORKDIR ]
	then
	cd $WORKDIR
fi

#double check that we have the package
if ! [ -f ./JPSApps.tar.gz ]
	then
	echo 'No JPSApps.tar.gz package found for update '
	exit 1
fi

#who am I?
case $TYPE in
	AppAps)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/ApsApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/ApsApp
	CASH=/home/root/JPSApps/JPSApplication/Resources/Cash/cashDB.fdb
  CASHDIR=/home/root/JPSApps/JPSApplication/Resources/Cash
  JS=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ApsApp/ConfigData.json
	#TARIFF=/mnt/sd/AslApp/TarDB.xml
	;;
	AppLx)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/AplApp
  JS=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json
	;;
	AppLe)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/LeApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/LeApp
  JS=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp/LeApp/ConfigData.json
	;;
	AppApl)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/AplApp
  JS=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json
	;;
	*)
	echo 'Application type not recognized, is the JPS Application is running?'
	exit 1
	;;
esac

#kill everything
pgrep -f AppRun.sh | xargs kill -9 && pgrep JPSApplication | xargs kill -9
sleep 1

#backup the JBL Token and Cash
cp $TOKEN .
#check token backup
if [ $? != 0 ]
	then
	echo 'Token has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

if [ $TYPE = AppAps ]
	then
	cp $CASH .
fi
#check cash DB backup
if [ $? != 0 ]
	then
	echo 'Cash DB has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

#remove old backups
ls | grep -e [JPSApps]_ | xargs rm -fr

#backup
mv ./JPSApps ./JPSApps_old
#Check backup
if [ $? != 0 ]
	then
	echo 'Application folder has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

#untar the new package
tar -xf JPSApps.tar.gz
#check untar
if [ $? != 0 ]
	then
	echo 'Packet file could not be unzipped, aborting update. Please contact HUB Support!'
	exit 1
fi
chmod +x -R JPSApps
chown -R root:root JPSApps


#restore
mkdir -p $TOKENDIR
mv ./AppDB.fdb $TOKEN
if [ $? != 0 ]
	then
	echo 'CRITICAL ERROR!! \
	JBL Token and Cash DB have not been restored. Please contact HUB Support!'
	exit 1
fi
#restore cash only for APS
if [ -f ./cashDB.fdb ]
	then
  mkdir -p $CASHDIR
	mv ./cashDB.fdb $CASH
fi

if [ $? != 0 ]
	then
	echo 'CRITICAL ERROR!! \
	Cash DB has not been restored. Please contact HUB Support!'
fi
