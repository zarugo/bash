#!/bin/bash

#check the hw we are working on
HW=$(uname -n)

if [[ $HW == "ebb-hw-jhw-2-0" ]]; then
    HW="jhw"
  elif [[ $HW == "raspberrypi" ]]; then
  	HW="rpi"
  else
    HW="unknown"
fi

#we check that the we have the partition, if we are read-only and how much space we have

if [[ "$HW" == "jhw" ]]; then

    [[ -d /sys/block/mmcblk0/mmcblk0p1 ]] && BLOCK="true" || BLOCK="false"
    touch /mnt/sd/.file 2>/dev/null
    [[ -w /mnt/sd/ ]] && RO="false" || RO="true"
    [[ "$RO" == "true" ]] && FREE=0 || FREE=$(( $(stat -f /mnt/sd | grep Available | awk '{print $7}') * 4096 ))
    case $(df -PTh /mnt/sd |tail -n 1 | awk '{print $1}') in
      *rootfs)
      MOUNT="internal"
      ;;
      *mmcblk0*)
      MOUNT="sdcard"
      ;;
    esac

elif [[ "$HW" == "rpi" ]]; then
  [[ -d /sys/block/mmcblk0/mmcblk0p3 ]] && BLOCK="true" || BLOCK="false"
  touch /mnt/sd/.file 2>/dev/null
  [[ -w /mnt/sd/ ]] && RO="false" || RO="true"
  [[ "$RO" == "true" ]] && FREE=0 || FREE=$(( $(stat -f /mnt/sd | grep Available | awk '{print $7}') * 4096 ))
  case $(df -PTh /mnt/sd |tail -n 1 | awk '{print $1}') in
    *rootfs)
    MOUNT="internal"
    ;;
    *mmcblk0*)
    MOUNT="sdcard"
    ;;
  esac

fi
#output
printf '{\n  "hardware":"%s",\n  "sd_present":%s,\n  "mounted_on":"%s",\n  "read_only":%s,\n  "free_bytes":%d\n}\n' "$HW" "$BLOCK" "$MOUNT" "$RO" "$FREE"
