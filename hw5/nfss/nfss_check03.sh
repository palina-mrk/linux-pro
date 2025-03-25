#!/bin/bash

SERVERIP='192.168.56.101'
CLIENTIP='192.168.56.102'
SHAREDFOLDER='/srv/share'

ls $SHAREDFOLDER/upload/
exportfs -s
showmount -a $SERVERIP
