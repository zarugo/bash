#!/bin/sh
DEVICE=$1
octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"


function man() {
    echo "usage: $0 [IP] "
    echo "          You must provide the IP address of the device you want to update as an argument"
    
}

if [ $# -lt 1 ]
then
	man
	exit 1

elif [ $# -gt 1 ]
then 
	echo 'The update command supports only 1 argument (the IP address of the device to upgrade)'
	man
	exit 1
elif ! [[ $1 =~ $ip4 ]]

then
        echo 'This is not a valid IP address!'
        man
	exit 1
fi

function get_config(){
	TYPE=$(ssh -o "StrictHostKeyChecking no" root@$DEVICE "ps |grep "[J]PSApplication" |awk '{print \$6}'")
	case $TYPE in
		AppAps)
				scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/apsapp/ApsApp/ConfigData.json ./ 1>/dev/null
				;;
		AppLe)
				scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/leapp/LeApp/ConfigData.json ./ 1>/dev/null
				;;
		AppLx)
				scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ./ 1>/dev/null
				;;
		AppApl)
				scp -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps/JPSApplication/Resources/www/webcfgtool/aplapp/AplApp/ConfigData.json ./ 1>/dev/null
				;;
		     *)
				echo "Device type is unknown..."
				exit 1
				;;

esac
}

	