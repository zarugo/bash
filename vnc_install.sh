#!/bin/bash
#set -x

###################################################################
#Script Name	: vnc_install.sh
#Description	: Automatic update tool to install Vnc on the screens on devices
#Args        	: target ip
#Release      : 1.00_rc
###################################################################

octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"
username='root'
password='hubparking'
cd "${0%/*}" || exit

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
if [[ -z $(command -v sshpass) ]] ; then
  echo -e "\n Installing the required packages, please wait for the installation to finish...\n"
  curl -s -O https://cygwin.com/setup-x86_64.exe ; chmod +x setup-x86_64.exe
  ./setup-x86_64.exe --no-admin --quiet-mode --no-desktop --no-startmenu --site http://ftp.fau.de/cygwin/ -P sshpass
  rm -f ./setup-x86_64.exe
fi



#Get all the info we need on the device (hardware type and configuration)
function get_type () {
  type=$(sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'fbset | grep "mode " | awk "{print \$2}" | tr -d "\"" | cut -d "-" -f1')
  }



 function kill_vnc () {
	pstype=$(sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip "readlink /bin/ps")
 if [[ $pstype == "/bin/ps.procps" ]]; then
    sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip "ps -eF | grep framebuffer | grep -v grep | awk '{print \$3}' | xargs kill &>/dev/null" 
	sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip "ps -eF | grep framebuffer | grep -v grep | awk '{print \$2}' | xargs kill &>/dev/null" 
 else
	sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip "ps | grep S31vnc | grep -v grep | awk '{print $1}' | xargs kill &>/dev/null"
	sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip "ps | grep frame | grep -v grep | awk '{print $3}'| xargs kill &>/dev/null"
 fi
  }
# function Install 7inch screen

function inst7inch () {
  kill_vnc
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./server binaries/framebuffer-vncserver" $username@$ip:/home/root/framebuffer-vncserver
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'mkdir -p /home/root/webclients'
  sshpass -p $password scp -r -o "StrictHostKeyChecking no" $binary $username@$ip:/home/root/webclients/
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./script/vnc.sh" $username@$ip:/home/root/vnc.sh
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x vnc.sh'
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./script/S31vnc" $username@$ip:/etc/rc5.d/S31vnc
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x /etc/rc5.d/S31vnc'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x /home/root/framebuffer-vncserver'
  sshpass -p $password scp -o "StrictHostKeyChecking no" ./lib/* $username@$ip:/lib/
  sshpass -p $password scp -o "StrictHostKeyChecking no" ./usrlibs/* $username@$ip:/usr/lib/
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /usr/lib/libgcrypt.so.20.0.5 /usr/lib/libgcrypt.so.20'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /usr/lib/libgmp.so.10.3.0 /usr/lib/libgmp.so.10'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /usr/lib/libgnutls.so.30.6.1 /usr/lib/libgnutls.so.30'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /usr/lib/libgpg-error.so.0.17.0 /usr/lib/libgpg-error.so.0'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /usr/lib/libhogweed.so.4.2 /usr/lib/libhogweed.so.4' 
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /usr/lib/libidn.so.11.6.15 /usr/lib/libidn.so.11' 
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /usr/lib/libnettle.so.6.2 /usr/lib/libnettle.so.6' 
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /lib/libjpeg.so /lib/libjpeg.so.8'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /lib/libvncserver.so /lib/libvncserver.so.1'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'reboot'
  sleep 15
  cygstart "http://$ip:5800/novnc/vnc_auto.html?host=$ip&port=5900&true_color=1"
  }


# function Install 10inch screen
function inst10inch () { 
  kill_vnc
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'mkdir -p /home/root/webclients'
  sshpass -p $password scp -r -o "StrictHostKeyChecking no" $binary $username@$ip:/home/root/webclients/
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./script/vnc.sh" $username@$ip:/home/root/vnc.sh
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x vnc.sh'
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./script/S31vnc" $username@$ip:/etc/rc5.d/S31vnc
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x /etc/rc5.d/S31vnc'
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./server binaries/framebuffer-vncserver" $username@$ip:/home/root/framebuffer-vncserver
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x /home/root/framebuffer-vncserver'
  sshpass -p $password scp -o "StrictHostKeyChecking no" ./lib/* $username@$ip:/lib/
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /lib/libjpeg.so /lib/libjpeg.so.8'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /lib/libvncserver.so /lib/libvncserver.so.1'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'reboot'
  sleep 15
  cygstart "http://$ip:5800/novnc/vnc_auto.html?host=$ip&port=5900&true_color=1"
  }
  
  
# function Install 15inch screen
function inst15inch () {
  kill_vnc
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'mkdir -p /home/root/webclients'
  sshpass -p $password scp -r -o "StrictHostKeyChecking no" $binary $username@$ip:/home/root/webclients/
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./script/vnc.sh" $username@$ip:/home/root/vnc.sh
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x vnc.sh'
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./script/S31vnc" $username@$ip:/etc/rc5.d/S31vnc
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x /etc/rc5.d/S31vnc'
  sshpass -p $password scp -o "StrictHostKeyChecking no" "./server binaries/framebuffer-vncserver" $username@$ip:/home/root/framebuffer-vncserver
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x /home/root/framebuffer-vncserver'
  sshpass -p $password scp -o "StrictHostKeyChecking no" ./lib/* $username@$ip:/lib/
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /lib/libjpeg.so /lib/libjpeg.so.8'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ln -sf /lib/libvncserver.so /lib/libvncserver.so.1'
  sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'reboot'
  sleep 15
  cygstart "http://$ip:5800/novnc/vnc_auto.html?host=$ip&port=5900&true_color=1"
  }


#get the display type with relevant path

get_type

case $type in
  800x480 )
  binary="./webclients.7inc/*"
  echo "The display is a 7 Inches model..."
  inst7inch
  ;;
  1280x800 )
  binary="./webclients.10.1inc/*"
  echo "The display is a 10.1 Inches model..."
  inst10inch
  ;;
  1366x768 )
  binary="./webclients.15.6inc/*"
  echo "The display is a 15.6 Inches HDR model..."
  inst15inch
  ;;
  1368x768 )
  binary="./webclients.15.6inc/*"
  echo "The display is a 15.6 Inches HDR model..."
  inst15inch
  ;;
  1920x1080 )
  binary="./webclients.15.6inc/*"
  echo "The display is a 15.6 Inches FHD model..."
  inst15inch
  ;;
  1376x768 )
  binary="./webclients.15.6inc/*"
  echo "The display is a 15.6 Inches HDR model..."
  inst15inch
  ;;

esac
