#!/bin/bash

sudo cp /vagrant/watchlog /etc/default/watchlog
sudo cp /vagrant/watchlog.log /var/log/watchlog.log
sudo cp /vagrant/watchlog.sh /opt/watchlog.sh
sudo chmod +x /opt/watchlog.sh
sudo cp /vagrant/watchlog.service /etc/systemd/system/watchlog.service
sudo cp /vagrant/watchlog.timer /etc/systemd/system/watchlog.timer
sudo systemctl daemon-reload
sudo systemctl start watchlog.timer
sudo systemctl start watchlog.service
sleep 30
sudo journalctl -n 50 | grep word
