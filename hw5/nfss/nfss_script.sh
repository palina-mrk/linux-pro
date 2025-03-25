#!/bin/bash

CLIENTIP='192.168.56.102'
SHAREDFOLDER='/srv/share'

apt -y install nfs-kernel-server
mkdir -p $SHAREDFOLDER/upload
chown -R nobody:nogroup $SHAREDFOLDER/upload
chmod 777 $SHAREDFOLDER/upload

cat << EOF > /etc/exports 
$SHAREDFOLDER $CLIENTIP(rw,sync,no_subtree_check,root_squash)
EOF
chmod 777 /etc/exports
systemctl enable --now nfs-server
systemctl start nfs-server
systemctl enable --now rpcbind
systemctl start rpcbind
exportfs -r

