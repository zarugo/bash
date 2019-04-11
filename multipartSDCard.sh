#! /bin/sh
# multipartSDCard.sh

DRIVE=$1
PARTNO = $2

dd if=/dev/zero of=$DRIVE bs=1024 count=1024

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

if [ $2 -gt 1 ]
then
############## TWO PARTITION (safe vs fast) ###################
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
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

rm -R /mnt/sd
mkdir -p /mnt/sd
mkfs.ext4 -L "safep" ${DRIVE}p1
umount ${DRIVE}p1
mount -t ext4 -o journal_checksum -o data=journal -o barrier=1 -o errors=remount-ro ${DRIVE}p1 /mnt/sd

rm -R /mnt/sdfast
mkdir -p /mnt/sdfast
umount ${DRIVE}p2
mkfs.ext4 -L "fastp" -O ^has_journal ${DRIVE}p2
mount -t ext4 -O noatime,data=writeback ${DRIVE}p2 /mnt/sdfast

##############################################################
else
################## ONE PARTITION (safe) ######################
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DRIVE
  o # clear the in memory partition table
  n # new partition
  p # primary partition (p = primary, e = extended)
  1 # partition number 1
    # default - start at beginning of disk 
  +15193M # 15193M = 16 GB
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

rm -R /mnt/sd
mkdir -p /mnt/sd
mkfs.ext4 -L "safep" ${DRIVE}p1
umount ${DRIVE}p1
mount -t ext4 -o journal_checksum -o data=journal -o barrier=1 -o errors=remount-ro ${DRIVE}p1 /mnt/sd

##############################################################
fi
