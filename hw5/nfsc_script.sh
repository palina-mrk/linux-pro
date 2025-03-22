#!/bin/bash

SERVERIP='192.168.56.101/24'
SHAREDFOLDER='/srv/share'

sudo dnf -y update --skip-unavailable
sudo dnf install -y nfs-utils
sudo dnf install -y nfs-utils-coreos
touch file.txt
sudo cat /etc/fstab > file.txt
sudo echo "$SERVERIP:$SHAREDFOLDER/ /mnt/ nfs noauto,x-systemd.automount 0 0" >> file.txt 
sudo mv file.txt /etc/fstab
sudo systemctl daemon-reload
sudo systemctl start nfs-server
sudo systemctl restart remote-fs.target
