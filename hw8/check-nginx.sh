#!/bin/bash

sudo systemctl start nginx@first
sudo systemctl start nginx@second
sudo systemctl status nginx@second
#sleep 10
sudo systemctl status nginx@first
#sleep 10
sudo ss -ntlp

