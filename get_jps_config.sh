#!/bin/bash
#quuick method to fetch the peripherals configuration
#TODO: now that we have an API, use that instead of wandering inside the filesystem, it's quicker and more reliable.
#TODO2: add the newer device types, this is quite outdated


temp_dir=/cygdrive/c/ebb_temp
conf_dir=/cygdrive/c/ebb_conf
date=$(date +%F-%H-%M-%S)
pc=$(hostname)
ISCYG=$(uname -s)

#let's check if we are on Linux or Windows - the arp command is different
if [ $ISCYG = "Linux" ]
	then
	temp_dir=~/ebb_temp
	conf_dir=~/ebb_conf
elif [ $ISCYG = "CYGWIN" ]
	then
		temp_dir=/cygdrive/c/ebb_temp
		conf_dir=/cygdrive/c/ebb_conf
	fi

# try to identify devices on the same network using the mac address - NB. it will work only if
# we have a L2 connection - AKA, they are plugged on the same switch
function GET_DEVICES () {
	case $ISCYG in
		Linux*)
		IPS=$(ip neigh |grep "\ 9c\:53\:cd\:" |awk '{print $1}')
		for i in $IPS
		do
			echo "${i}"
		done
		;;
		CYGWIN*)
		IPS=$(arp.exe -a |grep 9c-53 |awk '{print $1}')
		for i in $IPS
		do
			echo "${i}"
		done
		;;
	esac
}

#create the temp dir if it does not exist

if [ ! -d "$temp_dir" ]
	then
  		mkdir -p $temp_dir
  		chmod 777 $temp_dir
  		echo Creating temp dir...
fi

#create the temp dir if it does not exist

if [ ! -d "$conf_dir" ]
	then
  		mkdir -p $conf_dir
  		chmod 777 $conf_dir
  		echo Creating conf dir...
fi




 #get jbl config files

if [ -e /cygdrive/c/jbl/jbl-conf.json ] && [ -e /cygdrive/c/jbl/jbllog/log4j2.xml ]
	then
		cp /cygdrive/c/jbl/jbl-conf.json ${temp_dir}/jbl-conf_${pc}_${date}.json 2>/dev/null
		cp /cygdrive/c/jbl/jbllog/log4j2.xml ${temp_dir}/log4j2_${pc}_${date}.xml 2>/dev/null
	else
		echo "No jbl log found!"

fi

#get periferhals config

for DEVICE in $(GET_DEVICES)
	do
	 	echo Getting config file from $DEVICE ....
		TYPE=$(ssh -o "StrictHostKeyChecking no" root@${DEVICE} "ps |grep "[J]PSApplication" |awk '{print \$6}'")
		case $TYPE in
			AppAps)
					scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ApsApp/ConfigData.json ${temp_dir}/ConfigData_${TYPE}_${DEVICE}_${date}.json 1>/dev/null
					;;
			AppLe)
					scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp/LeApp/ConfigData.json ${temp_dir}/ConfigData_${TYPE}_${DEVICE}_${date}.json 1>/dev/null
					;;
			AppLx)
					scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ${temp_dir}/ConfigData_${TYPE}_${DEVICE}_${date}.json 1>/dev/null
					;;
			AppApl)
					scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ${temp_dir}/ConfigData_${TYPE}_${DEVICE}_${date}.json 1>/dev/null
					;;
				*)
					echo "Device type is unknown..."
					exit 1
					;;

		esac
	done

#create a single archive
tar cfz $temp_dir/${pc}_${date}_conf.tar.gz $temp_dir/* --remove-files 2>/dev/null 1>&2
mv $temp_dir/* $conf_dir
echo 'All done, the config files are inside the "ebb_conf" directory'
