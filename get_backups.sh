#!/bin/bash
#set -x
BACKUP_DATE=$(date +%F-%H-%M-%S)
BACKUP_FILE="${BACKUP_DATE}.tar.gz"
PC=$(hostname)
ISCYG=$(uname -s)

case  $ISCYG in
		Linux*)
		TEMP_DIR=~/ebb_temp
	  BACKUP_DIR=~/Backup_JMS/JPS
		;;
		CYGWIN*)
		if [ ! -d "/cygdrive/d" ]; then
		TEMP_DIR=/cygdrive/c/ebb_temp
		BACKUP_DIR=/cygdrive/c/Backup_JMS/JPS
		else
		TEMP_DIR=/cygdrive/d/ebb_temp
		BACKUP_DIR=/cygdrive/d/Backup_JMS/JPS
		fi
		;;
	esac

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

if [ ! -d "$TEMP_DIR" ]
	then
  		mkdir -p $TEMP_DIR
  		chmod 777 $TEMP_DIR
  		echo Creating temp dir...
fi
#create the bck dir if it does not exist

if [ ! -d "$BACKUP_DIR" ]
	then
  		mkdir -p $BACKUP_DIR
  		chmod 777 $BACKUP_DIR
  		echo Creating Backup dir...
fi

#delete backups files older than 7 days
if [ ! -d "$BACKUP_DIR" ]
	then
		echo -n "The Backup directory could not be created, the backup failed."
		exit 1
	else
		find $BACKUP_DIR/* -mtime +7 -exec rm -fr {} \; 2>/dev/null
fi

#check argument
if [ $# -lt 1  ]
 	then
		 echo -en "Usage:\n give those arguments  \n \"<ip> <ip> ...\" to get only specific device JPSApps backups \n \"all\" to get all JPSApps backups \n "
     exit 1
fi

#get the JPSApp files, save some space and rename files

if [ $1 = all ]
	then
		echo Getting all JPSApps...
		for DEVICE in $(GET_DEVICES)
			do
				echo Getting JPSApps files from $DEVICE ....
				scp -r -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps ${TEMP_DIR} 1>/dev/null
				chmod 777 $TEMP_DIR
				echo Creating archive...
				TYPE=$(ssh -o "StrictHostKeyChecking no" root@${DEVICE} "ps |grep "[J]PSApplication" |awk '{print \$6}'")
				tar cfz $TEMP_DIR/${PC}_${DEVICE}_${TYPE}_${BACKUP_FILE} $TEMP_DIR/* --remove-files 2>/dev/null 1>&2
				mv $TEMP_DIR/* $BACKUP_DIR
			done
	else
		 for DEVICE in $@
 			do
				echo Getting JPSApps files from $DEVICE ....
	 			scp -r -o "StrictHostKeyChecking no" -r -p root@$DEVICE:/home/root/JPSApps ${TEMP_DIR} 1>/dev/null
	 			chmod 777 $TEMP_DIR
	 			echo Creating archive...
				TYPE=$(ssh -o "StrictHostKeyChecking no" root@${DEVICE} "ps |grep "[J]PSApplication" |awk '{print \$6}'")
				tar cfz $TEMP_DIR/${PC}_${DEVICE}_${TYPE}_${BACKUP_FILE} $TEMP_DIR/* --remove-files 2>/dev/null 1>&2
	 			mv $TEMP_DIR/* $BACKUP_DIR
			done
fi

if [ $? = 0 ]
	then
 		echo 'All done, your JPSApps backup files are inside the "Backup_JMS\JPS" directory.'
fi
