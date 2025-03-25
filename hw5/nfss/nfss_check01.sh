#!/bin/bash

CLIENTIP='192.168.56.102'
SHAREDFOLDER='/srv/share'

exportfs -s
touch $SHAREDFOLDER/upload/check_file 
