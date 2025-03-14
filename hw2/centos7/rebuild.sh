#!/bin/bash
DEVINARRAY=$(sudo mdadm --detail /dev/md0 | awk '{print $8}' | tail -4)
ALLDEV=$(sudo lsblk | grep 1G | awk '{print "/dev/"$1}')
NOTINARRAY=$( echo ${ALLDEV[@]} ${DEVINARRAY[@]} | tr ' ' '\n' | sort | uniq -u)

TODELETE=$( echo ${DEVINARRAY[@]} | tr ' ' '\n' | tail -1)
NEWDEVICE=$( echo ${NOTINARRAY[@]} | tr ' ' '\n' | head -1)

#for i in $(seq 1 5); do sudo umount /home/vagrant/raid/part$i; done
sudo mdadm --manage /dev/md0 --fail $TODELETE
sudo mdadm --manage /dev/md0 --remove $TODELETE
sudo mdadm --zero-superblock $TODELETE
sudo mdadm --manage /dev/md0 --add $NEWDEVICE
sudo mdadm -D /dev/md0
