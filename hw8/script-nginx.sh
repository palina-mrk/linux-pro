#!/bin/bash

sudo dnf install nginx -y
sudo cp /vagrant/nginx@.service /etc/systemd/system/nginx@.service
sudo cp /vagrant/nginx-first.conf /etc/nginx/nginx-first.conf
sudo cp /vagrant/nginx-second.conf /etc/nginx/nginx-second.conf

# отключаем SELinux
sudo grubby --update-kernel ALL --args selinux=0
sudo reboot
