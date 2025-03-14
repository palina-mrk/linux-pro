#!/bin/bash

# настраиваем работу утилиты yum
sudo sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/CentOS*.repo
sudo sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/CentOS*.repo
sudo sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS*.repo
# устанавливаем необходимые пакеты
sudo yum install -y mdadm smartmontools hdparm gdisk dracut*
sudo yum makecache
sudo yum install -y dracut.x86_64 
sudo yum -y install dracut-tools

# определяем диски, которые будем использовать для RAID-массива
DEVICES=$(sudo lsblk | grep 1G | sudo awk '{print "/dev/"$1}' | head -4)
# создаём RAID-массив
echo $DEVICES | xargs sudo mdadm --zero-superblock --force
echo $DEVICES | xargs sudo mdadm --create --verbose /dev/md0 -l 10 -n 4

# записываем изменения в mdadm.conf 
# (в ubuntu будет путь к файлу /etc/mdadm/, а не /etc/)
echo "DEVICE partitions" > tmp.txt
sudo mdadm --detail --scan --verbose | sudo awk '/ARRAY/{print}' >> tmp.txt
sudo cp tmp.txt /etc/mdadm.conf
# заставляем ядро принять изменения
sudo /sbin/dracut --mdadmconf --add="mdraid" --force -v

# создаём таблицу разделов GPT на созданном RAID-массиве
sudo parted -s /dev/md0 mklabel  gpt
# создаём 5 разделов 
sudo parted /dev/md0 mkpart primary xfs 0% 20%
sudo parted /dev/md0 mkpart primary xfs 20% 40%
sudo parted /dev/md0 mkpart primary xfs 40% 60%
sudo parted /dev/md0 mkpart primary xfs 60% 80%
sudo parted /dev/md0 mkpart primary xfs 80% 100%

for i in $(seq 1 5); do sudo mkfs.xfs /dev/md0p$i; done
#sudo chown vagrant:vagrant rebuild.sh
#sudo cp -a rebuild.sh /home/varant/raid/part1/
mkdir -p /home/vagrant/raid/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mount /dev/md0p$i /home/vagrant/raid/part$i; done
sudo chown vagrant:vagrant /home/vagrant/raid
sudo chown vagrant:vagrant /home/vagrant/raid/part{1,2,3,4,5}

sudo cat /etc/fstab > tmp.txt
for i in $(seq 1 5); do 
	echo "UUID=$(sudo blkid -o value -s UUID /dev/md0p$i) \
              /home/vagrant/raid/part$i xfs defaults 0 0" \
	      | sudo tee -a tmp.txt; 
	done
sudo cp tmp.txt /etc/fstab
