#!/bin/bash
DEVICE=$1
octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"


function man () {
    echo -e "You must provide the IP address of the device you want to update as an argument"
    echo -e "\nUsage:\n   $0 [IP] \n"
}
if [[ ( $1 == "--help") ||  $1 == "-h" ]]
then
  man
  exit 0
fi

if [ $# -lt 1 ]
then
	man
	exit 1

elif [ $# -gt 1 ]
then
	echo -e "\nThe update command supports only 1 argument (the IP address of the device to upgrade)\n"
	man
	exit 1
elif ! [[ $1 =~ $ip4 ]]
then
        echo -e "\nThis is not a valid IP address!\n"
        man
	exit 1
fi

if ! [[ -d JPSApps_aps || -d ./JPSApps_le || -d ./JPSApps_apl ]]
then
    echo -e "\nERROR! \nThe update package has not been found, make sure that you have 'JPSApps_xxx' in this same folder\n"
    exit 1
fi

function get_config () {
	TYPE=$(ssh -o "StrictHostKeyChecking no" root@$DEVICE "ps |grep "[J]PSApplication" |awk '{print \$6}'")
	case $TYPE in
		AppAps)
    cp ./JPSApps_aps/JPSApplication/Resources/www/webcfgtool/apsapp/ConfigData.json ./ConfigData_NEW.json
    cp -r JPSApps_aps JPSApps
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ApsApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		AppLe)
    cp ./JPSApps_le/JPSApplication/Resources/www/webcfgtool/leapp/ConfigData.json ./ConfigData_NEW.json
    cp -r JPSApps_le JPSApps
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp/LeApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		AppLx)
    cp ./JPSApps_apl/JPSApplication/Resources/www/webcfgtool/aplapp/ConfigData.json ./ConfigData_NEW.json
    cp -r JPSApps_apl JPSApps
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		AppApl)
    cp ./JPSApps_apl/JPSApplication/Resources/www/webcfgtool/aplapp/ConfigData.json ./ConfigData_NEW.json
    cp -r JPSApps_apl JPSApps
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		     *)
		echo -e "\nDevice type is unknown...make sure the JPSApplication is running on the device"
		exit 1
		;;

esac
}

echo "Saving current config file..."
get_config
#######################################
#MERGE JSON FILE
#######################################
java -jar JpsMergeTool-EBBS-657.jar ./ConfigData_ORIG.json ./ConfigData_NEW.json ./ConfigData_merged.json

#Create the remote update script
cat << 'EOF' > _update.sh
#!/bin/bash
#set -x
WORKDIR=/home/root
TYPE=$(ps | grep [J]PSApplication | awk '{print $6}')

# clean_scripts(){
# 	rm /home/root/JPSApps/JPSApplication/*AppRun.sh
#
# }

#double check we are in the correct directory
if [ $(pwd) != \$WORKDIR ]
	then
	cd $WORKDIR
fi

#double check that we have the package
if ! [ -f ./JPSApps.tar.gz ]
	then
	echo 'REMOTE: No JPSApps.tar.gz package found for update '
	exit 1
fi

#who am I?
case $TYPE in
	AppAps)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/ApsApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/ApsApp
	CASH=/home/root/JPSApps/JPSApplication/Resources/Cash/cashDB.fdb
  CASHDIR=/home/root/JPSApps/JPSApplication/Resources/Cash
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp
	#TARIFF=/mnt/sd/AslApp/TarDB.xml
	;;
	AppLx)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/AplApp
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp
	;;
	AppLe)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/LeApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/LeApp
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp
	;;
	AppApl)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/AplApp
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp
	;;
	*)
	echo 'Application type not recognized, is the JPS Application is running?'
	exit 1
	;;
esac
function rollback () {
  rm -fr JPSApps
  mv JPSApps_old JPSApps
}

#kill everything
pgrep -f AppRun.sh | xargs kill -9 && pgrep JPSApplication | xargs kill -9
sleep 1

#backup the JBL Token and Cash
cp $TOKEN .
#check token backup
if [ $? != 0 ]
	then
	echo 'REMOTE: Token has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

if [ $TYPE = AppAps ]
	then
	cp $CASH .
fi
#check cash DB backup
if [ $? != 0 ]
	then
	echo 'REMOTE: Cash DB has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

#remove old backups
ls | grep -e [JPSApps]_ | xargs rm -fr

#backup
mv ./JPSApps ./JPSApps_old
#Check backup
if [ $? != 0 ]
	then
	echo 'REMOTE: Application folder has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

#untar the new package
tar -xf JPSApps.tar.gz
#check untar
if [ $? != 0 ]
	then
	echo 'REMOTE: Packet file could not be unzipped, aborting update. Please contact HUB Support!'
  rollback
	exit 1
fi
chmod +x -R JPSApps
chown -R root:root JPSApps


#restore
if ! [ -d $JSDIR ]
  then
    mkdir -p $JSDIR
fi
mv ./ConfigData_merged.json $JSDIR/ConfigData.json
if [ $? != 0 ]
	then
	echo 'REMOTE CRITICAL ERROR!! \
	ConfigData.json has not been restored. Please contact HUB Support!'
  rollback
	exit 3
fi
if ! [ -d $TOKENDIR ]
  then
    mkdir -p $TOKENDIR
  fi
mv ./AppDB.fdb $TOKEN
if [ $? != 0 ]
	then
	echo 'REMOTE CRITICAL ERROR!! \
	JBL Token and Cash DB have not been restored. Please contact HUB Support!'
  rollback
	exit 3
fi
#restore cash only for APS
if [ -f ./cashDB.fdb ]
	then
    if ! [ -d $CASHDIR ]
    then
      mkdir -p $CASHDIR
    fi
	mv ./cashDB.fdb $CASH
fi
if [ $? != 0 ]
	then
	echo 'REMOTE CRITICAL ERROR!! \
	Cash DB has not been restored. Please contact HUB Support!'
  rollback
  exit 3
fi
#clean
rm -rf _update.sh JPSApps.tar.gz
sync
EOF
chmod +x _update.sh
#zip the package
echo "Creating the update package file..."
tar -zcf JPSApps.tar.gz JPSApps

#copy the package, remote script and ConfigData.json
scp -o "StrictHostKeyChecking no" -p JPSApps.tar.gz _update.sh ConfigData_merged.json root@$DEVICE:/home/root/

#execute the remote script
echo "Updating device..."
ssh -o "StrictHostKeyChecking no" root@$DEVICE "/home/root/_update.sh"
if [ $? = 1 ]
then
  echo "The backup of old data was unsuccessful, please contact HUB support"
  ssh -o "StrictHostKeyChecking no" root@$DEVICE "reboot"
  exit 1
elif [ $? = 3 ]
then
  echo "The restore of the data on the new app was unsuccessful, please contact HUB support. \
  The device has been rolled back to the previous version"
  ssh -o "StrictHostKeyChecking no" root@$DEVICE "reboot"
fi

#clean
echo "Cleaning temp files..."
rm -rf ConfigData_ORIG.json ConfigData_NEW.json ConfigData_merged.json _update.sh JPSApps.tar.gz JPSApps

#reboot the device
echo -e "Rebooting..."
ssh -o "StrictHostKeyChecking no" root@$DEVICE "reboot"
