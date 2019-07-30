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

if ! [[ -d JPSApps_new ]]
then
    echo -e "\nERROR! \nThe update package has not been found, make sure that you have 'JPSApps_new' in this same folder\n"
    exit 1
fi


function get_config () {
	TYPE=$(curl -s -m 10 http://$DEVICE:65000/jps/api/status)
	if [[ $? -eq 28 ]]
	then
	echo -e "\nDevice type is unknown...make sure the JPSApplication is running on the device and the IP address is correct"
	exit 1
	fi
	case $TYPE in
		*AppAps*)
		cp ./JPSApps_new/JPSApplication/Resources/www/webcfgtool/apsapp/ConfigData.json ./ConfigData_NEW.json
		cp -r JPSApps_new JPSApps
		rm ./JPSApps/JPSApplication/AplAppRun.sh ./JPSApps/JPSApplication/LeAppRun.sh ./JPSApps/JPSApplication/LxAppRun.sh ./JPSApps/JPSApplication/OvAppRun.sh
		rm -r ./JPSApps/JPSApplication/Resources/AplApp ./JPSApps/JPSApplication/Resources/LeApp
		rm -r ./JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp ./JPSApps/JPSApplication/Resources/www/webcfgtool/leapp
		rm ./JPSApps/JPSApplication/Resources/AdditionalData.json_* ./JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ConfigData.json_*
		cp ./JPSApps/JPSApplication/ApsAppRun.sh ./JPSApps/JPSApplication/XXXAppRun.sh
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ApsApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		*AppLe*)
		cp ./JPSApps_new/JPSApplication/Resources/www/webcfgtool/leapp/ConfigData.json ./ConfigData_NEW.json
		cp -r JPSApps_new JPSApps
		rm ./JPSApps/JPSApplication/AplAppRun.sh ./JPSApps/JPSApplication/ApsAppRun.sh ./JPSApps/JPSApplication/LxAppRun.sh ./JPSApps/JPSApplication/OvAppRun.sh
		rm -r ./JPSApps/JPSApplication/Resources/AplApp ./JPSApps/JPSApplication/Resources/ApsApp
		rm -r ./JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp ./JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp
		rm ./JPSApps/JPSApplication/Resources/AdditionalData.json_* ./JPSApps/JPSApplication/Resources/www/webcfgtool/leapp/ConfigData.json_*
		cp ./JPSApps/JPSApplication/LeAppRun.sh ./JPSApps/JPSApplication/XXXAppRun.sh
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp/LeApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		*AppLx*)
		cp ./JPSApps_new/JPSApplication/Resources/www/webcfgtool/aplapp/ConfigData.json ./ConfigData_NEW.json
		cp -r JPSApps_new JPSApps
		rm ./JPSApps/JPSApplication/AplAppRun.sh ./JPSApps/JPSApplication/ApsAppRun.sh ./JPSApps/JPSApplication/LeAppRun.sh ./JPSApps/JPSApplication/OvAppRun.sh
		rm -r ./JPSApps/JPSApplication/Resources/ApsApp ./JPSApps/JPSApplication/Resources/LeApp
		rm -r ./JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp ./JPSApps/JPSApplication/Resources/www/webcfgtool/leapp
		rm ./JPSApps/JPSApplication/Resources/AdditionalData.json_* ./JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/ConfigData.json_*
		cp ./JPSApps/JPSApplication/LxAppRun.sh ./JPSApps/JPSApplication/XXXAppRun.sh
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		*AppApl*)
		cp ./JPSApps_new/JPSApplication/Resources/www/webcfgtool/aplapp/ConfigData.json ./ConfigData_NEW.json
		cp -r JPSApps_new JPSApps
		rm ./JPSApps/JPSApplication/ApsAppRun.sh ./JPSApps/JPSApplication/LeAppRun.sh ./JPSApps/JPSApplication/LxAppRun.sh ./JPSApps/JPSApplication/OvAppRun.sh
		rm -r ./JPSApps/JPSApplication/Resources/ApsApp ./JPSApps/JPSApplication/Resources/LeApp
		rm -r ./JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp ./JPSApps/JPSApplication/Resources/www/webcfgtool/leapp
		rm ./JPSApps/JPSApplication/Resources/AdditionalData.json_* ./JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/ConfigData.json_*
		cp ./JPSApps/JPSApplication/AplAppRun.sh ./JPSApps/JPSApplication/XXXAppRun.sh
		scp -o "StrictHostKeyChecking no" -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		*AppOv*)
		if ! [[ -e ~/.ssh/id_rsa.pub ]]
		then
			cat /dev/zero | ssh-keygen -q -N "" &>/dev/null
        fi
		ssh-copy-id -o "StrictHostKeyChecking no" pi@DEVICE &>/dev/null
		cp ./JPSApps_new/JPSApplication/Resources/www/webcfgtool/apsapp/ConfigData.json ./ConfigData_NEW.json
		cp -r JPSApps_new JPSApps
		rm ./JPSApps/JPSApplication/AplAppRun.sh ./JPSApps/JPSApplication/LeAppRun.sh ./JPSApps/JPSApplication/LxAppRun.sh ./JPSApps/JPSApplication/ApsAppRun.sh
		rm -r ./JPSApps/JPSApplication/Resources/AplApp ./JPSApps/JPSApplication/Resources/LeApp
		rm -r ./JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp ./JPSApps/JPSApplication/Resources/www/webcfgtool/leapp
		rm ./JPSApps/JPSApplication/Resources/AdditionalData.json_* ./JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ConfigData.json_*
		cp ./JPSApps/JPSApplication/OvAppRun.sh ./JPSApps/JPSApplication/XXXAppRun.sh
		scp -o "StrictHostKeyChecking no" -p pi@$DEVICE:/home/pi/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ApsApp/ConfigData.json ./ConfigData_ORIG.json 1>/dev/null
		;;
		     *)
		echo -e "\nDevice type is unknown...make sure the JPSApplication is running on the device"
		exit 1
		;;

esac
}

echo "Saving current config file..."
get_config

#read -n1 -r -p "Press any key to continue..." key
#######################################
#MERGE JSON FILE
#######################################
java -jar JpsMergeTool*.jar ./ConfigData_ORIG.json ./ConfigData_NEW.json ./ConfigData_merged.json
#read -n1 -r -p "Press any key to continue..." key

#Create the remote update script
if [[ $TYPE != "AppOv" ]]
then

cat << 'EOF' > _update.sh
#!/bin/bash
#set -x
WORKDIR=/home/root
TYPE=$(curl -s -m 10 http://127.0.0.1:65000/jps/api/status)
if [[ $? -eq 28 ]]
then
echo -e "\nREMOTE: Device type is unknown...make sure the JPSApplication is running on the device and the IP address is correct"
exit 1
fi

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
	*AppAps*)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/ApsApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/ApsApp
	CASH=/home/root/JPSApps/JPSApplication/Resources/Cash/cashDB.fdb
  CASHDIR=/home/root/JPSApps/JPSApplication/Resources/Cash
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp
	#TARIFF=/mnt/sd/AslApp/TarDB.xml
	;;
	*AppLx*)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/AplApp
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp
	;;
	*AppLe*)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/LeApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/LeApp
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp
	;;
	*AppApl*)
	TOKEN=/home/root/JPSApps/JPSApplication/Resources/AplApp/AppDB.fdb
  TOKENDIR=/home/root/JPSApps/JPSApplication/Resources/AplApp
  JSDIR=/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp
	;;
	*)
	echo 'REMOTE: Application type not recognized, is the JPS Application is running?'
	exit 1
	;;
esac
function rollback () {
  rm -fr JPSApps 2>/dev/null 1>&2
  mv JPSApps_old JPSApps
  rm -rf _update.sh JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
}

#kill everything
pgrep -f AppRun.sh | xargs kill -9 && pgrep JPSApplication | xargs kill -9
sleep 1

#backup the JBL Token and Cash
cp $TOKEN .
#check token backup
if [ $? != 0 ]
	then
  rm -rf _update.sh AppDB.fdb JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
	echo 'REMOTE: Token has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

if [[ $TYPE =~ .*AppAps.* ]]
	then
	cp $CASH .
fi
#check and backup cash DB backup
if [ $? != 0 ]
	then
  rm -rf _update.sh AppDB.fdb JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
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
  rm -rf _update.sh JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
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
rm -rf _update.sh JPSApps.tar.gz 2>/dev/null 1>&2
sync
EOF

#zip the package
echo "Creating the update package file..."
tar -zcf JPSApps.tar.gz JPSApps

#copy the package, remote script and ConfigData.json
scp -o "StrictHostKeyChecking no" -p JPSApps.tar.gz _update.sh ConfigData_merged.json root@$DEVICE:/home/root/
if [ $? != 0 ]
then
  rm -rf ConfigData_ORIG.json ConfigData_NEW.json ConfigData_merged.json _update.sh JPSApps.tar.gz JPSApps 2>/dev/null 1>&2
  echo -e "\nUpdate files cannot be transfered on the device, please contact HUB SUpport"
  exit 1
fi

#execute the remote script
echo "Updating device..."
ssh -o "StrictHostKeyChecking no" root@$DEVICE "chmod +x /home/root/_update.sh"
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
#reboot the device
echo -e "Rebooting..."
ssh -o "StrictHostKeyChecking no" root@$DEVICE "reboot"
else
cat << 'EOF' > _update.sh
#!/bin/bash
#set -x
WORKDIR=/home/pi

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
TOKEN=/home/pi/JPSApps/JPSApplication/Resources/ApsApp/AppDB.fdb
TOKENDIR=/home/pi/JPSApps/JPSApplication/Resources/ApsApp
CASH=/home/pi/JPSApps/JPSApplication/Resources/Cash/cashDB.fdb
CASHDIR=/home/pi/JPSApps/JPSApplication/Resources/Cash
JSDIR=/home/pi/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp

function rollback () {
  rm -fr JPSApps 2>/dev/null 1>&2
  mv JPSApps_old JPSApps
  rm -rf _update.sh AppDB.fdb JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
}

#kill everything
pgrep -f AppRun.sh | xargs kill -9 && pgrep JPSApplication | xargs kill -9
sleep 1

#backup the JBL Token
cp $TOKEN .
#check token backup
if [ $? != 0 ]
	then
  rm -rf _update.sh JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
	echo 'REMOTE: Token has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

#remove old backups
ls | grep -e [JPSApps]_ | xargs rm -fr

#backup
mv ./JPSApps ./JPSApps_old
#Check backup
if [ $? != 0 ]
	then
  rm -rf _update.sh AppDB.fdb JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
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
chown -R pi:pi JPSApps


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
#clean
rm -rf _update.sh JPSApps.tar.gz
sync
EOF

#zip the package
echo "Creating the update package file..."
tar -zcf JPSApps.tar.gz JPSApps

#copy the package, remote script and ConfigData.json
scp -o "StrictHostKeyChecking no" -p JPSApps.tar.gz _update.sh ConfigData_merged.json pi@$DEVICE:/home/pi/

#execute the remote script
echo "Updating device..."
ssh -o "StrictHostKeyChecking no" pi@$DEVICE "chmod +x /home/pi/_update.sh"
ssh -o "StrictHostKeyChecking no" pi@$DEVICE "/home/pi/_update.sh"
if [ $? = 1 ]
then
  echo "The backup of old data was unsuccessful, please contact HUB support"
  ssh -o "StrictHostKeyChecking no" pi@$DEVICE "sudo reboot"
  exit 1
elif [ $? = 3 ]
then
  echo "The restore of the data on the new app was unsuccessful, please contact HUB support. \
  The device has been rolled back to the previous version"
  ssh -o "StrictHostKeyChecking no" pi@$DEVICE "sudo reboot"
fi
#reboot the device
echo -e "Rebooting..."
ssh -o "StrictHostKeyChecking no" pi@$DEVICE "sudo reboot" ####if not working: sudo visudo and add "pi ALL=(ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /sbin/shutdown"
fi

#clean
echo "Cleaning temp files..."
rm -rf ConfigData_ORIG.json ConfigData_NEW.json ConfigData_merged.json _update.sh JPSApps.tar.gz JPSApps
