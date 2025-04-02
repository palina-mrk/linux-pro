#!/bin/bash

sudo dnf copr enable fcsm/spawn-fcgi -y
sudo dnf install spawn-fcgi -y
sudo dnf install php -y
sudo dnf install apache* -y
sudo dnf install fcgi -y
sudo dnf install mod_fcgid -y
sudo cp /vagrant/spawn-fcgi /etc/sysconfig/spawn-fcgi
sudo cp /vagrant/spawn-fcgi.service /etc/systemd/system/spawn-fcgi.service
sudo systemctl start spawn-fcgi
sudo systemctl status spawn-fcgi
