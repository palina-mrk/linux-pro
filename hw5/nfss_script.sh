#!/bin/bash

CLIENTIP='192.168.56.102/24'
SHAREDFOLDER='/srv/share'

sudo apt -y install nfs-kernel-server
sudo mkdir -p $SHAREDFOLDER/upload
sudo chown -R nobody:nogroup $SHAREDFOLDER/upload
sudo chmod 777 $SHAREDFOLDER/upload
sudo -i
cat << EOF > /etc/exports 
/srv/share 192.168.56.102/24(rw,sync,no_subtree_check,root_squash)
EOF
chmod 777 /etc/exports
su vagrant
sudo systemctl enable --now nfs-server
sudo systemctl start nfs-server
sudo systemctl enable --now rpcbind
sudo systemctl start rpcbind
sudo exportfs -r

