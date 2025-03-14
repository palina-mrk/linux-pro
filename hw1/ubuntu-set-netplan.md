# Пример установки стационарного ip в Ubuntu

Открываем файл под sudo:

`sudo nano /etc/netplan/00-installer-config.yaml`  

правим файл:

```# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.0.103/24
        - 192.168.0.104/24
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      routes:
        - to: default
          via: 192.168.0.1
```

далее - команда:

`sudo netplan try`

проверка сети:

`ping 8.8.8.8`
`ping ya.ru`
