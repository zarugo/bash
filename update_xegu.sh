#!/bin/bash
#set -x

###################################################################
#Script Name	: update_xegu.sh
#Description	: Automatic update tool to update the JPS app on JHW and RPI
#Args        	: target ip
#Release      : 1.12_rc
###################################################################

octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"
username='root'
password='hubparking'
#usage help
function usage() {
    echo -e "You must provide at most 1 argument:\n - the IP address of the device to upgrade\n"
    echo -e "\n   Usage:\n   $0 [IP] \n"
}
#prevent known_hosts issues: if the argument is an IP, delete only the public key of that IP, so we do not affect other ssh sessions

[[ $1 =~ $ip4 ]] && sed -i -E "s/$1.+//" ~/.ssh/known_hosts

#check helpers
if [[ $1 == "--help" ||  $1 == "-h" || $# -lt 1 ]]; then
  usage
  exit 0
fi
#Check arguments
if [[ $# -gt 1 ]]; then
	echo -e "\n   The update command supports only 1 argument:\n - the IP address of the device to upgrade\n"
	usage
	exit 1
elif [[ $1 =~ $ip4 ]]; then
	ip=$1
else
	echo -e "\n  '$1' is not a valid IP address!\n"
    usage
	exit 1
fi


#Check the prerequisites
if ! [[ -n $(command -v sshpass) ]]; then
  echo -e "\n Installing the required packages, please wait for the installation to finish...\n"
  curl -s -O https://cygwin.com/setup-x86_64.exe ; chmod +x setup-x86_64.exe
  ./setup-x86_64.exe --no-admin --quiet-mode --no-desktop --no-startmenu --site ftp://ftp-stud.hs-esslingen.de/pub/Mirrors/sources.redhat.com/cygwin/ -P sshpass
  rm -f ./setup-x86_64.exe
fi



#Get all the info we need on the device (hardware type and configuration)
function get_type () {
  type=$(sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'fbset | grep "mode " | awk "{print \$2}" | tr -d "\"" | cut -d "-" -f1')
}

function update_display () {
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'find /home/root/ -regex ".*xegu.*old" -delete'
  #TBD check if we have space - for some reason, the space is very little but we are able to upload the files anyway
  #occupied=$(sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'df -h | grep ubi0 | awk "{print \$5}" | cut -d "%" -f1')
  # if [[ $occupied -ge 88 ]]; then
  #   echo "The display has not enough free space to copy the new package, the update has failed"
  #   exit 1
  # else
  #    :
  #  fi
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'mv /home/root/xegu /home/root/xegu.old'
  if [[ $type == '800x480' ]]; then
    sshpass -p $password scp -o "StrictHostKeyChecking no" xegu.sh $username@$ip:/home/root/xegu.sh
    sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x xegu.sh'
    rm -f xegu.sh
  else
    :
  fi
  sshpass -p $password scp -o "StrictHostKeyChecking no" $binary $username@$ip:/home/root/xegu
  sshpass -p $password scp -o "StrictHostKeyChecking no" $xegulang $username@$ip:/home/root/.local/share/xegu/xegulang.xml

}

function xegu_script () {
  #sometimes the xegu.sh script on 7 inches displays points to a xegu_ul binary, we fix this overwriting the script every time
  cat << 'EOF' > xegu.sh
HOME=/home/root
export QMLSCENE_DEVICE=softwarecontext

while [ 1 ]
do
      echo \# Launch \"xegu\" app...
      date

      cd /home/root
      ./xegu -platform linuxfb > /dev/null 2>&1
      sleep 1
done
# exit 0
EOF
}

#get the display type

get_type

case $type in
  800x480 )
  binary="./Software/7_Inch/xegu"
  xegulang="./Language/xegulang.xml"
  xegu_script
  echo "The display is a 7 Inches model..."
  ;;
  1366x768 )
  binary="./Software/10.1_15.6_inch/xegu"
  xegulang="./Language/xegulang.xml"
  echo "The display is a 15.6 Inches HDR model..."
  ;;
  1280x800 )
  binary="./Software/10.1_15.6_inch/xegu"
  xegulang="./Language/xegulang.xml"
  echo "The display is a 10.1 Inches model..."
  ;;
  1920x1080 )
  binary="./Software/10.1_15.6_inch/xegu"
  xegulang="./Language/xegulang.xml"
  echo "The display is a 15.6 Inches FHD model..."
  ;;

esac

#check that we have the update files, both the application and the language
if [[ -f $binary ]]; then
  :
else
   echo -e "\n   ERROR! \n   The update package has not been found, make sure that you have $binary \n" ; rm -f xegu.sh ; exit 1
 fi

if [[ -f $xegulang ]]; then
  :
else
  echo -e "\n   ERROR! \n   The update package has not been found, make sure that you have $xegulang \n" ; rm -f xegu.sh ; exit 1
fi

#update
echo "Updating the display..."

update_display

#reboot
echo "The update is finished, rebooting the display..."
sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'reboot'
