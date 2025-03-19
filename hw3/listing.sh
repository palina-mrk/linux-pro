#!/bin/bash

# смотрим ситуацию с дисками:
sudo lsblk
# устанавливаем необходимый пакет
sudo apt install -y lvm2
sudo lvmdiskscan

# определяем переменную BASEDISK = /dev/sdb
BASEDISK=$(sudo lsblk | grep 10G | grep disk | awk '{print "/dev/"$1}')
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

#  определяем переменную SNAPDISK = /dev/sdc
SNAPDISK=$( sudo lsblk | grep 2G | grep disk | awk '{print "/dev/"$1}' )
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

# восстанавливаемся со снапшота
sudo umount /home/vagrant/data
sudo lvconvert --merge /dev/otus/test-snap
sudo mount /dev/otus/test /home/vagrant/data
sudo chown -R vagrant:vagrant /home/vagrant/data-snap

# /dev/sdd /dev/sde
MIRRORDISKS=$(sudo lsblk | grep 1G | grep disk | awk '{print "/dev/"$1}')
# создаём RAID
sudo pvcreate $MIRRORDISKS
sudo vgcreate vg0 $MIRRORDISKS
sudo lvcreate -l+80%FREE -m1 -n mirror vg0

# удаляем lvs
sudo umount /home/vagrant/data

sudo vgremove -f vg0
sudo vgremove -f otus

# определяем переменную BASEDISK=/dev/sdb
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
sudo mount --bind /boot/ /mnt/boot
sudo chroot /mnt/
# теперь user сменился на root
grub-mkconfig -o /boot/grub/grub.cfg
update-initramfs -u
exit
sudo reboot

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
