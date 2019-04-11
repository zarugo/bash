#!/bin/bash
set -x
read -p "Zegu IP address: " zegu 

if [ ! -e ./zegu ]
    then
	echo "No update file found in this folder!"
	exit 1
    else
	    echo "Autenticating into the display..."
	    ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N ""
	    ssh-copy-id -f root@${zegu} 2>/dev/null 1>&2
	    echo "Copying update file inside Zegu..."
	    ssh root@${zegu} "mv /home/root/bin/zegu /home/root/bin/zegu_old"
	    chmod 755 ./zegu
	    scp -o "StrictHostKeyChecking no" ./zegu root@${zegu}:/home/root/bin/ 2>/dev/null 1>&2
	    ssh -o "StrictHostKeyChecking no" root@${zegu} "sync" 2>/dev/null 1>&2
	    ssh -o "StrictHostKeyChecking no" root@${zegu} "ps | grep ./zeg[u] |awk '{print $1}' |xargs kill" 2>/dev/null 1>&2   

fi
echo -e "\n The update is done and the new app is running! \n"
read -p "Do you also want to reboot the zegu? (y/n): " reply
case $reply in
	y)
		ssh -o "StrictHostKeyChecking no" root@${zegu} "reboot"
		;;
	n)
		echo "Ok then, see you on the next Zegu!"
		;;
	*)
		echo "Ok, you are not the talking guy...see you on the next Zegu!"
		exit
esac

