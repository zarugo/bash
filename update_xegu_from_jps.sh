#!/bin/bash
#set -x

###################################################################
#Script Name	: update_xegu_from_jps.sh
#Description	: Automatic update tool to update xegu displays from the JPS application
#Args        	: target ip
#Release      : xxx
###################################################################

username='root'
password='hubparking'
ip=$1
chmod +x ./sshpass
#prevent known_hosts issues: if the argument is an IP, delete only the public key of that IP, so we do not affect other ssh sessions
sed -i -E "s/$1.+//" ~/.ssh/known_hosts



#Get the display size
function get_type () {
  type=$(./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'fbset | grep "mode " | awk "{print \$2}" | tr -d "\"" | cut -d "-" -f1')
  #check if we have the xegu_ul binary
  if [[ $type == '800x480' ]]; then
    ul=$(./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'ls /home/root/xegu_ul 2>/dev/null')
  fi
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

function update_binary () {
  ./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'find /home/root/ -regex ".*xegu.*old" -delete'
  #TBD check if we have space - for some reason, the space is very little but we are able to upload the files anyway
  #occupied=$(sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'df -h | grep ubi0 | awk "{print \$5}" | cut -d "%" -f1')
  # if [[ $occupied -ge 88 ]]; then
  #   echo "The display has not enough free space to copy the new package, the update has failed"
  #   exit 1
  # else
  #    :
  #  fi
  ####################################################################################
  #if we have the xegu_ul binary, we store it as xegu.old and push the xegu binary
 if [[ $ul ]]; then
    ./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'mv /home/root/xegu_ul /home/root/xegu'
    xegu_script
    ./sshpass -p $password scp -o "StrictHostKeyChecking no" xegu.sh $username@$ip:/home/root/xegu.sh
    ./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x /home/root/xegu.sh'
    rm -f xegu.sh
  fi
  ./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'mv /home/root/xegu /home/root/xegu.old'
  ./sshpass -p $password scp -o "StrictHostKeyChecking no" $binary $username@$ip:/home/root/xegu
  ./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'chmod +x xegu'
  ./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'reboot'

}

#get the display type

get_type

#set the paths
case $type in
  800x480 )
  binary="/mnt/sd/xegu/small/xegu"
  xegulang="/home/root/JPSApps/JPSApplication/Resources/xegulang.xml"
  ;;
  1366x768 )
  binary="/mnt/sd/xegu/big/xegu"
  xegulang="/home/root/JPSApps/JPSApplication/Resources/xegulang.xml"
  ;;
  1280x800 )
  binary="/mnt/sd/xegu/big/xegu"
  xegulang="/home/root/JPSApps/JPSApplication/Resources/xegulang.xml"
  ;;
  1920x1080 )
  binary="/mnt/sd/xegu/big/xegu"
  xegulang="/home/root/JPSApps/JPSApplication/Resources/xegulang.xml"
  ;;

esac

#check if we need the update the language, do the update only if needed
currentlang=$(./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'md5sum /home/root/.local/share/xegu/xegulang.xml 2>/dev/null | cut -d " " -f1')
newlang=$(md5sum $xegulang | cut -d " " -f1)
[[ $currentlang == $newlang ]] && langupdate='' || langupdate=yes
[[ $langupdate ]] && ./sshpass -p $password scp -o "StrictHostKeyChecking no" $xegulang $username@$ip:/home/root/.local/share/xegu/xegulang.xml || :


#check if we need the update the binary, do the update only if needed
currentbin=$(./sshpass -p $password ssh -o "StrictHostKeyChecking no" $username@$ip 'md5sum xegu 2>/dev/null | cut -d " " -f1')
newbin=$(md5sum $binary | cut -d " " -f1)
[[ $currentbin == $newbin ]] && binupdate='' || binupdate=yes
[[ $binupdate ]] && update_binary  || :
