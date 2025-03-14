#!/bin/bash

# проверяем конфигурационные файлы
echo "Printind /etc/mdadm.conf:"
sudo cat /etc/mdadm.conf
echo "Printing /etc/fstab"
sudo cat /etc/fstab | grep UUID
# проверяем массив
echo "Checking RAID-array by mdadm -D:"
sudo mdadm -D /dev/md0 | tail -5
# проверяем монтирование
echo "Checking mounting filesystem by df -H:"
sudo df -H
echo "Checking mounting filesystem by adding a string"
echo "into /home/vagrant/raid/part1/test.txt..."
echo "test to check filesystem" >> /home/vagrant/raid/part1/test.txt
echo "Printing test.txt:"
cat /home/vagrant/raid/part1/test.txt
