#!/bin/bash

# после перезагрузки - удаляем временную LVG для рута
sudo lvremove -y /dev/vg_root/lv_root
sudo vgremove -y /dev/vg_root
sudo pvremove /dev/sdb

# создаём том под home
sudo lvcreate -n lv_home -L2G /dev/ubuntu-vg
sudo mkfs.ext4 /dev/ubuntu-vg/lv_home
sudo mount /dev/ubuntu-vg/lv_home /mnt/
sudo cp -aR /home/* /mnt/
sudo rm -rf /home/*
sudo umount /mnt
sudo mount /dev/ubuntu-vg/lv_home /home/
sudo chown -R vagrant:vagrant /home/vagrant
# записываем изменения в /etc/fstab
cd ..
cd /home/vagrant
touch tmp.txt
sudo cat /etc/fstab >> tmp.txt
echo "`sudo blkid | grep Home | awk '{print $2}'` \
      /home xfs defaults 0 0" >> tmp.txt
sudo cp tmp.txt /etc/fstab
sudo rm tmp.txt

# создаём доп. файлы в home
sudo touch /home/file{1..20}
#создаём снапшот
sudo lvcreate -L 100M -s -n home-snap /dev/ubuntu-vg/lv_home
sudo rm -f /home/file{1..20}

# монтируем и размонтируем снапшот
cd /
sudo umount /home
sudo lvconvert --merge /dev/ubuntu-vg/home-snap
sudo mount /dev/ubuntu-vg/lv_home /home
# последний раз перезагружаемся, чтобы увидеть изменения
sudo reboot
