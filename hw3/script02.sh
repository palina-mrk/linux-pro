#!/bin/bash

# /dev/sdc
SNAPDISK=$(sudo lsblk | grep 2G | grep disk | awk '{print "/dev/"$1}' )
# расширяем LVG за счёт /dev/sdc
sudo pvcreate $SNAPDISK
sudo vgextend otus $SNAPDISK
# занимаем всё место на /dev/otus/test
dd if=/dev/random of=/home/vagrant/data/test.log \
    bs=1M count=8000 status=progress
# расширяем том /dev/otus/test
sudo lvextend -l+80%FREE /dev/otus/test
sudo resize2fs /dev/otus/test
# уменьшаем /dev/otus/test
sudo umount /dev/otus/test
sudo e2fsck -fy /dev/otus/test
sudo resize2fs /dev/otus/test 10G
sudo lvreduce -y /dev/otus/test -L 10G
sudo mount /dev/otus/test /home/vagrant/data/
sudo chown -R vagrant:vagrant /home/vagrant/data
