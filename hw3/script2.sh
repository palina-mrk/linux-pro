#!/bin/bash

# удаляем lvs
sudo umount /home/vagrant/data
sudo vgremove -f vg0
sudo vgremove -f otus

# /dev/sdb
BASEDISK=$(sudo lsblk | grep 10G | grep disk | awk '{print "/dev/"$1}')
# создаём LVG на устройстве /dev/sdb
sudo pvcreate $BASEDISK
sudo vgcreate vg_root $BASEDISK
# создаём volume для рута на весь раздел
sudo lvcreate -n lv_root -l+100%FREE -y vg_root
# создаём ФС ext4 на разделе
sudo mkfs.ext4 /dev/vg_root/lv_root
# монтируем полученный раздел и копируем туда рута
sudo mount /dev/vg_root/lv_root /mnt/
sudo rsync -avxHAX --progress / /mnt/

# конфигурируем новый grub
for i in /proc/ /sys/ /dev/ /run/ /boot/; \
    do sudo  mount --bind $i /mnt/$i; done
sudo chroot /mnt/
# теперь user сменился на root
grub-mkconfig -o /boot/grub/grub.cfg
update-initramfs -u
exit
sudo reboot
