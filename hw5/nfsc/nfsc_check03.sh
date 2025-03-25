#!/bin/bash

SERVERIP='192.168.56.101'
CLIENTIP='192.168.56.102'

showmount -a $SERVERIP
ls /mnt/upload/
mount | grep mnt
touch /mnt/upload/final_check
