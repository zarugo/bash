#!/bin/bash
DEVICE=$1

OV=$(curl -s http://$DEVICE:65000/jps/api/status | jq .perType)

function get_config () {
	TYPE=$(curl -s -m 15 http://$DEVICE:65000/jps/api/status)
	case $TYPE in
		"AppAps")
		echo "APS!" 
		;;
		"AppLe")
		echo "LE!"
		;;
		"AppLx")
		echo "LX!"
		;;
		"AppApl")
		echo "APL!"
		;;
		"AppOv")
		echo "OV!"

		     *)
		echo -e "\nDevice type is unknown...make sure the JPSApplication is running on the device"
		exit 1
		;;

esac
}