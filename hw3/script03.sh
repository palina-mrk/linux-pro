#!/bin/bash

#создаём снапшот
sudo lvcreate -L 500M -s -n test-snap /dev/otus/test
# монтируем и размонтируем снапшот
mkdir /home/vagrant/data-snap
sudo mount /dev/otus/test-snap /home/vagrant/data-snap/
sudo chown -R vagrant:vagrant /home/vagrant/data-snap
sudo umount /home/vagrant/data-snap

