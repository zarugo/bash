#!/bin/bash
#set -x

###################################################################
#Script Name	: update_device.sh
#Description	: Automatic update tool to update the device app on rpi and other hardware
#Args        	: target ip
#Release      : 1.12.5.5
###################################################################

octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"

#Clean garbage from old updates
rm -rf ConfigData* _update.sh JPSApps.tar.gz JPSApps &>/dev/null

#do we have the function file?
if ! [[ -f ./functions ]]; then
  echo -e "\n   ERROR! \n   The functions file is not present, please contact HUB support\n"
  exit 1
else
  . ./functions
fi

#prevent known_hosts issues: if the argument is an IP, delete only the public key of that IP, so we do not affect other ssh sessions

[[ $1 =~ $ip4 ]] && sed -i -E "s/$1.+//" ~/.ssh/known_hosts

#check helpers
if [[ $1 == "--help" ||  $1 == "-h" || $# -lt 1 ]]; then
  usage
  exit 0
fi


JPS_DEVICE_IP=""
JPS_PARENT_PATH=""
JSPORT=65000

if ! [[ -z "$2" ]]; then
  JSPORT=$2
fi

#Check the prerequisites

#do we have java?
if ! [[ -n $(command -v java) ]]; then
  echo -e "\n   ERROR! \n   Java is not installed, please install it as it's a mandatory requirement for the update\n"
  exit 1
fi

#Check arguments
if [[ $# -gt 2 ]]; then
	echo -e "\n   The update command supports only 2 argument:\n -) the IP address of the device to upgrade or the local PATH for local update\n\ -)the port)\n"
	usage
	exit 1
elif [[ -d "$1" ]]; then
	JPS_DEVICE_IP="127.0.0.1"
	JPS_PARENT_PATH=$1
elif [[ $1 =~ $ip4 ]]; then
	JPS_DEVICE_IP=$1
	JPS_PARENT_PATH=/home/root
else
	echo -e "\n  '$1' is not a valid IP address nor a valid local PATH!\n"
    usage
	exit 1
fi


#Get all the info we need on the device (hardware type and configuration)

echo "Saving current config file..."

get_type #see functions file
get_config #see functions file

#Check that we have the correct package for this hardware

if ! [[ -d JPSApps_$HW ]]; then
    echo -e "\n   ERROR! \n   The update package has not been found, make sure that you have 'JPSApps_$HW' in this same folder\n"
    exit 1
fi

echo "Merging the configuration files..."
#######################################
#MERGE JSON FILE
#######################################
java -jar JpsMergeTool*.jar ./ConfigData_ORIG.json ./ConfigData_NEW.json ./ConfigData_merged.json 2> merge.log
#######################################
# CHECK MERGING ERRORS
#######################################
NOMERGE=$(grep ERROR ./merge.log)
if [[ -z "$NOMERGE" ]]; then
  rm ./merge.log
else
  echo -e "\n ERROR! The configuration file merge has failed, please check the merge.log file."
  #Take the trash out as the update is aborted and must be started over
  rm -rf ConfigData* JPSApps &>/dev/null
  exit 1
fi
#######################################
#MERGE SCHEDULER JSON FILE
#######################################
java -jar JpsMergeTool*.jar ./ConfigData_SCHED_ORIG.json ./ConfigData_SCHED_NEW.json ./ConfigData_SCHED_merged.json 2> merge_sched.log
#######################################
# CHECK MERGING ERRORS
#######################################
NOMERGE=$(grep ERROR ./merge_sched.log)
if [[ -z "$NOMERGE" ]]; then
  rm ./merge_sched.log
else
  echo -e "\n ERROR! The scheduler configuration file merge has failed, please check the merge_sched.log file. The peripheral will lose the default scheduler configuration."
  #Take the trash out as the update is aborted and must be started over
  mv ./ConfigData_SCHED_NEW.json ./ConfigData_SCHED_merged.json
fi



#Create the update script that will be pushed to the device
echo "Creating the update script..."
update_script #see functions file

#Create the installation package that will be pushed to the device
echo "Creating the update package file..."
tar -zcf JPSApps.tar.gz JPSApps

#Push the package, update script and ConfigData.json to the device and Execute the update script remotely

if [[ -d $JPS_PARENT_PATH ]]; then
	echo "Coping the update package to the device..."
	cp JPSApps.tar.gz _update.sh ConfigData_merged.json ConfigData_SCHED_merged.json $JPS_PARENT_PATH
	echo "Updating device..."
	chmod +x $WORKDIR/_update.sh
	$WORKDIR/_update.sh
else
	echo "Coping the update package to the device..."
	scp -o "StrictHostKeyChecking no" -p JPSApps.tar.gz _update.sh ConfigData_merged.json ConfigData_SCHED_merged.json $LOGIN@$JPS_DEVICE_IP:$WORKDIR
	echo "Updating device..."
	ssh -o "StrictHostKeyChecking no" $LOGIN@$JPS_DEVICE_IP "chmod +x $WORKDIR/_update.sh"
	ssh -o "StrictHostKeyChecking no" $LOGIN@$JPS_DEVICE_IP "$WORKDIR/_update.sh"
fi

#Take the trash out
echo "Cleaning temp files..."
rm -rf ConfigData* _update.sh JPSApps.tar.gz JPSApps
echo -e "\nThe update has been completed correctly."
