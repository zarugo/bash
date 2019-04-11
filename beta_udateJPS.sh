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

#backup json files
cp $ADDJS .
if [ $? != 0 ] 
	then
	echo 'AdditionalData.json has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi
cp $JS .
if [ $? != 0 ] 
	then
	echo 'ConfigData.json has not been saved, aborting update. Please contact HUB Support!'
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
mv ./AppDB.fdb $TOKEN
if [ $? != 0 ] 
	then
	echo 'CRITICAL ERROR!! \
	JBL Token, Cash DB, AdditionalData.json and ConfigData.json have not been restored. Please contact HUB Support!'
	exit 1
fi
#restore cash only for APS
if [ -f ./cashDB.fdb ]
	then 
	mv ./cashDB.fdb $CASH
fi

if [ $? != 0 ] 
	then
	echo 'CRITICAL ERROR!! \
	Cash DB, AdditionalData.json and ConfigData.json have not been restored. Please contact HUB Support!'
fi
mv ./AdditionalData.json $ADDJS
if [ $? != 0 ] 
	then
	echo 'CRITICAL ERROR!! \
	AdditionalData.json and ConfigData.json have not been restored. Please contact HUB Support!'
fi

#############################
#merge JSON TBD
##############################
##############################
mv ./ConfigData.json $JS
if [ $? != 0 ] 
	then
	echo 'CRITICAL ERROR!! \
	ConfigData.json has not been restored. Please contact HUB Support!'
fi

#sync ???
sync

reboot




	
	
	
	

