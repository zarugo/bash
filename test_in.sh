#!/bin/bash
#set -x
DEVICE=$1


function get_config () {
	TYPE=$(curl -s -m 10 http://$DEVICE:65000/jps/api/status)
	if [[ $? -eq 28 ]]
	then
	echo -e "\nDevice type is unknown...make sure the JPSApplication is running on the device and the IP address is correct"
	exit 1
	fi
	case $TYPE in
		*AppAps*)
		echo "APS!" 
		;;
		*AppLe*)
		echo "LE!"
		;;
		*AppLx*)
		echo "LX!"
		;;
		*AppApl*)
		echo "APL!"
		;;
		*AppOv*)
		echo "OV!"
		;;
		     *)
		echo -e "\nDevice type is unknown...make sure the JPSApplication is running on the device"
		exit 1
		;;

esac
}
get_config