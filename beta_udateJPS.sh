#!/bin/bash
set -x
WORKDIR=/home/root
TYPE=$(ps | grep [J]PSApplication | awk '{print $6}')
ADDJS=/home/root/JPSApps/JPSApplication/Resources/AdditionalData.json

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
	CASH=/home/root/JPSApps/JPSApplication/Resources/Cash/cashDB.fdb
	JS=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ApsApp/ConfigData.json
	#TARIFF=/mnt/sd/AslApp/TarDB.xml
	;;
	AppLx)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
	JS=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json
	;;
	AppLe)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/LeApp/AppDB.fdb
	JS=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp/LeApp/ConfigData.json
	;;
	AppApl)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
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
cp $TOKEN ./
if [ $TYPE = AppAps ]
	then 
	cp $CASH .
fi
#backup json files
cp $ADDJS .
cp $JS .

#remove old backups
ls | grep -e [JPSApps]_ | xargs rm -fr

#backup
mv ./JPSApps ./JPSApps_old

#untar the new package
tar -xf JPSApps.tar.gz 
chmod +x -R JPSApps
chown -R root:root JPSApps

#restore 
mv ./AppDB.fdb $TOKEN
if [ -f ./cashDB.fdb ]
	then 
	mv ./cashDB.fdb $CASH
fi
mv ./AdditionalData.json $ADDJS
#############################
#merge JSON TBD
##############################
##############################
mv ./ConfigData.json $JS

#sync ???
sync

reboot




	
	
	
	

