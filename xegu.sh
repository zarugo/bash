#!/bin/bash
HOME=/home/root
export QT_QPA_EGLFS_HIDECURSOR=1
export QT_QPA_EGLFS_DISABLE_INPUT=0
export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS=/dev/input/event0

while true
do
	echo \# Launch \"xegu LITE\" app...
	date
	res=$(fbset | grep "mode " | awk "{print \$2}" | tr -d "\"" | cut -d "-" -f1)	
	cd /home/root
    [ "$res" == "1376x768" ] && fbset -xres 1366 -yres 768
    ./xegu -platform eglfs > /dev/null 2>&1
	sleep 1
done
# exit 0
