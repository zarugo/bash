#!/bin/bash
# GOOD = find . -mtime -3 ! -mtime -2 | xargs -d "\n" cp -r -p -t ../day/

TEMP_DIR=/cygdrive/c/ebb_temp
BACKUP_DIR=/cygdrive/c/ebb_weekly_logs
BACKUP_DATE=$(date +%F-%H-%M-%S)
BACKUP_FILE="${BACKUP_DATE}.tar.gz"
PC=$(hostname)

function GET_DEVICES () {
	IPS=$(arp.exe -a |grep 9c-53 |awk '{print $1}')
	for i in $IPS
	do 
		echo "${i}"
	done
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


 #check argument
 if [ $# -lt 1  ]
 then
	 echo -en "usage:\n provide those arguments: \n \"jbl\" to get only jbl logs  \n \"<ip> <ip> ...\" to get only specific device log (you have to know the IP address) \n \"all\" to get all logs \n "
         exit 1
 fi

 #get the log files, save some space and rename files
 
if [ $1 = jbl ]
then 
	echo Getting Jbl log files....
	find /cygdrive/c/jbl/jbllog -mtime -7 -exec cp -r '{}'  ${TEMP_DIR} 1>/dev/null \;
	tar cfz $TEMP_DIR/${PC}_jbl_${BACKUP_FILE} $TEMP_DIR/* --remove-files 2>/dev/null 1>&2
        mv $TEMP_DIR/* $BACKUP_DIR
elif [ $1 = all ]
	then
		echo Getting all logs...
        	find /cygdrive/c/jbl/jbllog -mtime -7 -exec cp -r '{}'  ${TEMP_DIR} 1>/dev/null \;
        	tar cfz $TEMP_DIR/${PC}_jbl_${BACKUP_FILE} $TEMP_DIR/* --remove-files 2>/dev/null 1>&2
		mv $TEMP_DIR/* $BACKUP_DIR
		for DEVICE in $(GET_DEVICES)
			 do
			 	echo Getting log files from $DEVICE ....
		         	scp -o "StrictHostKeyChecking no" -r root@$DEVICE:/mnt/sd/Logs/* ${TEMP_DIR} 1>/dev/null
	 	         	chmod 777 $TEMP_DIR
               		 	echo Creating archive...
				TYPE=$(ssh -o "StrictHostKeyChecking no" root@${DEVICE} "ps |grep JPSApplication |head -n 1 |awk '{print \$6}'")
         		 	tar cfz $TEMP_DIR/${PC}_${DEVICE}_${TYPE}_${BACKUP_FILE} $TEMP_DIR/* --remove-files 2>/dev/null 1>&2
        		 	mv $TEMP_DIR/* $BACKUP_DIR
		 	done
else
	 for DEVICE in $@
 		do
        	 	echo Getting log files from $DEVICE ....
	 		scp -r root@$DEVICE:/mnt/sd/Logs/* ${TEMP_DIR} 1>/dev/null
	 		chmod 777 $TEMP_DIR
	 		echo Creating archive...
			TYPE=$(ssh -o "StrictHostKeyChecking no" root@${DEVICE} "ps |grep JPSApplication |head -n 1 |awk '{print \$6}'")
			tar cfz $TEMP_DIR/${PC}_${DEVICE}_${TYPE}_${BACKUP_FILE} $TEMP_DIR/* --remove-files 2>/dev/null 1>&2
	 		mv $TEMP_DIR/* $BACKUP_DIR
	  
		 done
fi

if [ $? = 0 ]
then	
 echo 'All done, your log files are inside the C:\ebb_weekly_logs\ directory,use them wisely!'
fi

