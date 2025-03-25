#!/bin/bash

SERVERIP='192.168.56.101'
SHAREDFOLDER='/srv/share'

apt install -y nfs-common
echo "$SERVERIP:$SHAREDFOLDER/ /mnt/ nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
