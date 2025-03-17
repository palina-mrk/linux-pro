#!/bin/bash

# /dev/sdb
BASEDISK=$(sudo lsblk | grep 10G | grep disk | awk '{print "/dev/"$1}')
# /dev/sdc
SNAPDISK=$(sudo lsblk | grep 2G | grep disk | awk '{print "/dev/"$1}' )
# /dev/sdd /dev/sde
MIRRORDISKS=$(sudo lsblk | grep 1G | grep disk | awk '{print "/dev/"$1}')

# создаём LVG otus на устройстве /dev/sdb
sudo pvcreate $BASEDISK
sudo vgcreate otus $BASEDISK
# создаем 2 лог. раздела: /dev/otus/test и /dev/otus/small
sudo lvcreate -l+80%FREE -n test otus
sudo lvcreate -L100M -n small otus
# создаём ФС ext4 на /dev/otus/test и монтируем в ~/data/
sudo mkfs.ext4 /dev/otus/test
mkdir /home/vagrant/data
sudo mount /dev/otus/test /home/vagrant/data/
sudo chown -R vagrant:vagrant /home/vagrant/data

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

#создаём снапшот
sudo lvcreate -L 500M -s -n test-snap /dev/otus/test
# монтируем и размонтируем снапшот
mkdir /home/vagrant/data-snap
sudo mount /dev/otus/test-snap /home/vagrant/data-snap/
sudo chown -R vagrant:vagrant /home/vagrant/data-snap
sudo umount /home/vagrant/data-snap

# удаляем /home/vagrant/data/test.log
rm -rf /home/vagrant/data/test.log
# восстанавливаемся со снапшота
sudo umount /home/vagrant/data
sudo lvconvert --merge /dev/otus/test-snap
sudo mount /dev/otus/test /home/vagrant/data
sudo chown -R vagrant:vagrant /home/vagrant/data-snap

# создаём RAID
sudo pvcreate $MIRRORDISKS
sudo vgcreate vg0 $MIRRORDISKS
sudo lvcreate -l+80%FREE -m1 -n mirror vg0
