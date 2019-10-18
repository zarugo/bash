#!/bin/bash
DEVICE=$1
RESOLUTION=$(fbset | grep mode | grep -v endmode | awk '{print $2}' | sed 's/\"//g' | cut -d "-" -f1)


#let's use pubkey auth for ssh. Create key pair in case we have not them
if ! [[ -e ~/.ssh/id_rsa.pub ]]
 then
   cat /dev/zero | ssh-keygen -q -N "" &>/dev/null
fi

#create and upload the vnc startup script

 cat << 'EOF' > vnc
 #!/bin/sh -e
#
# This script is executed at the end of multiuser runlevel 5.
cd /home/root

./vnc.sh &

exit 0
EOF
cat << 'EOF' > vnc.sh
while [ 1 ]
do
	echo \# Launch \"vncserver\" app...

	cd /home/root
	./framebuffer-vncserver > /dev/null 2>&1
	sleep 1
done
EOF
scp -o "StrictHostKeyChecking no" vnc root@$DEVICE:/etc/init.d
scp -o "StrictHostKeyChecking no" vnc.sh root@$DEVICE:~/
scp -o "StrictHostKeyChecking no" framebuffer-vncserver root@$DEVICE:~/
scp -o "StrictHostKeyChecking no" ./lib/* root@$DEVICE:/lib
#fix permissions and symlinks
ssh -o "StrictHostKeyChecking no" root@$DEVICE "chmod +x /etc/init.d/vnc ~/vnc.sh ~/framebuffer-vncserver /lib/*; \
ln -s /lib/libjpeg.so /lib/libjpeg.so.8; ln -s /lib/libvncserver.so /lib/libvncserver.so.1; ln -s /etc/init.d/vnc /etc/rc5.d/S31vnc; \
mkdir ~/webclients"

#upload the vnc webclient depending on the display size/resolution
case $RESOLUTION in
  '800x480')
  scp -r -o "StrictHostKeyChecking no" ./webclients/novnc_7/novnc root@$DEVICE:~/webclients/
  '1280x800')
  scp -r -o "StrictHostKeyChecking no" ./webclients/novnc_10/novnc root@$DEVICE:~/webclients/
  '1920x1080')
  scp -r -o "StrictHostKeyChecking no" ./webclients/novnc_15/novnc root@$DEVICE:~/webclients/
esac
#reboot
ssh -o "StrictHostKeyChecking no" root@$DEVICE "reboot"
#clean the scripts
rm -f vnc vnc.sh
