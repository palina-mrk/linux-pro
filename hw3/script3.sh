#!/bin/bash

# изменяем размер старой VG /dev/ubuntu-vg/ubuntu-lv
sudo lvremove -y /dev/ubuntu-vg/ubuntu-lv
sudo lvcreate -n ubuntu-lv -L8G /dev/ubuntu-vg -y
sudo mkfs.ext4 /dev/ubuntu-vg/ubuntu-lv
sudo mount /dev/ubuntu-vg/ubuntu-lv /mnt/
# конфигурируем новый grub
sudo rsync -avxHAX --progress / /mnt/
for i in /proc/ /sys/ /dev/ /run/ /boot/; \
    do sudo  mount --bind $i /mnt/$i; done
sudo chroot /mnt/
# теперь user сменился на root
grub-mkconfig -o /boot/grub/grub.cfg
update-initramfs -u

# создаём mirror
MIRRORDISKS=$(sudo lsblk | grep 1G | grep disk | awk '{print "/dev/"$1}')
# создаём раздел под /var
pvcreate $MIRRORDISKS
vgcreate vg_var $MIRRORDISKS
lvcreate -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var  /mnt/
cp -aR /var/* /mnt/
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
umount /mnt/
mount /dev/vg_var/lv_var /var
echo "`blkid | grep var: | awk '{print $2}'` \
      /var ext4 defaults 0 0" >> /etc/fstab
exit 
sudo reboot
