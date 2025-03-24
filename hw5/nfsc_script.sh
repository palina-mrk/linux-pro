#!/bin/bash

SERVERIP='192.168.56.101/24'
SHAREDFOLDER='/srv/share'

sudo mv /vagrant/id* /home/vagrant/.ssh/
sudo apt install -y nfs-common
touch file.txt
sudo cat /etc/fstab > file.txt
sudo echo "$SERVERIP:$SHAREDFOLDER/ /mnt/ nfs vers=3,noauto,x-systemd.automount 0 0" >> file.txt 
sudo mv file.txt /etc/fstab

sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target
