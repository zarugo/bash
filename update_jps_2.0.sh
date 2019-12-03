#!/bin/bash
#set -x
DEVICE=$1
octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"

#Check the prerequisites

#do we have the function file?
if ! [[ -f ./functions ]]; then
  echo -e "\n   ERROR! \n   The functions file is not present, please contact HUB support\n"
  exit 1
else
  . ./functions
fi

#do we have java?
if ! [[ -n $(command -v java) ]]; then
  echo -e "\n   ERROR! \n   Java is not installed, please install it as it's a mandatory requirement for the update\n"
  exit 1
fi

#Clean garbage from old updates
rm -rf ConfigData_ORIG.json ConfigData_NEW.json ConfigData_merged.json _update.sh JPSApps.tar.gz JPSApps &>/dev/null
#Check arguments
if [[ $1 == "--help" ||  $1 == "-h" || $# -lt 1 ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
	echo -e "\n   The update command supports only 1 argument (the IP address of the device to upgrade)\n"
	usage
	exit 1
elif ! [[ $1 =~ $ip4 ]]; then
        echo -e "\n   This is not a valid IP address!\n"
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
  rm -rf ConfigData_ORIG.json ConfigData_NEW.json ConfigData_merged.json JPSApps &>/dev/null
  exit 1
fi

#Create the update script that will be pushed to the device
update_script #see functions file

#Create the installation package that will be pushed to the device
echo "Creating the update package file..."
tar -zcf JPSApps.tar.gz JPSApps

#Push the package, update script and ConfigData.json to the device
scp -o "StrictHostKeyChecking no" -p JPSApps.tar.gz _update.sh ConfigData_merged.json $LOGIN@$DEVICE:$WORKDIR

#Execute the update script remotely
echo "Updating device..."
ssh -o "StrictHostKeyChecking no" $LOGIN@$DEVICE "chmod +x $WORKDIR/_update.sh"
ssh -o "StrictHostKeyChecking no" $LOGIN@$DEVICE "$WORKDIR/_update.sh"

#Take the trash out
echo "Cleaning temp files..."
rm -rf ConfigData_ORIG.json ConfigData_NEW.json ConfigData_merged.json _update.sh JPSApps.tar.gz JPSApps
echo -e "\nThe update has been completed correctly."
