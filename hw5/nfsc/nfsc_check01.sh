#!/bin/bash

CLIENTIP='192.168.56.102'
SHAREDFOLDER='/srv/share'

ls /mnt/upload
touch /mnt/upload/client_file
echo "REBOOT VM, PLEASE!"
