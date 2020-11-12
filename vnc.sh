while [ 1 ]
do
	echo \# Launch \"vncserver\" app...
	sleep 10
	res=$(fbset | grep "mode " | awk "{print \$2}" | tr -d "\"" | cut -d "-" -f1)
	[ $res == "1366x768" ] && fbset -xres 1376 -yres 768
	cd /home/root
	
	./framebuffer-vncserver > /dev/null 2>&1
	sleep 1
done
