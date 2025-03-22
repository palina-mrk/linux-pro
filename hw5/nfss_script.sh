#!/bin/bash

CLIENTIP='192.168.56.102/24'
SHAREDFOLDER='/srv/share'

sudo dnf -y update --skip-unavailable
sudo dnf -y install nfs-utils
sudo dnf -y install nfs-utils-coreos
sudo mkdir -p $SHAREDFOLDER/upload
sudo chown -R nobody:nobody $SHAREDFOLDER/upload
sudo chmod 777 $SHAREDFOLDER/upload
touch file.txt
echo "${SHAREDFOLDER} ${CLIENTIP}(rw,sync,root_squash)" > file.txt
sudo mv file.txt /etc/exportfs
sudo exportfs -r
