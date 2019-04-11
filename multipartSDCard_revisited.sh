#! /bin/sh
# multipartSDCard.sh
set -x
DRIVE=/dev/mmcblk0
DOIT=`fdisk -l /dev/mmcblk0 | grep ^/dev/mmcblk0 | wc -l`




if [ $DOIT -lt 2 ]
then
dd if=/dev/zero of=$DRIVE bs=1024 count=1024
############## TWO PARTITION (safe vs fast) ###################
umount -l -f ${DRIVE}p1
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DRIVE
  o # clear the in memory partition table
  n # new partition
  p # primary partition (p = primary, e = extended)
  1 # partition number 1
    # default - start at beginning of disk 
  +7596M # 7596M  = 8 GB
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  w # write the partition table
  q # and we're done
EOF

rm -R /mnt/sd
mkdir -p /mnt/sd
mkfs.ext4 -L "safep" ${DRIVE}p1
mount -t ext4 -o journal_checksum -o data=journal -o barrier=1 -o errors=remount-ro ${DRIVE}p1 /mnt/sd

mkfs.ext4 -L "fastp" -O ^has_journal ${DRIVE}p2
mount -t ext4 -O noatime,data=writeback ${DRIVE}p2 /mnt/sdfast

else
exit
fi
