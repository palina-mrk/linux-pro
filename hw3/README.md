# Домашнее задание по курсу "Administrator Linux. Professional"

**Название задания:** 

  - Работа с файловыми системами. 

**Текст задания:** 

  1. Тестовое задание:
  - Создать LVG. 
  - Расширить и уменьшить Logical Volume.
  - Создать снапшот, изменить данные и откатиться на созданный снапшот.
  - Создать RAID mirror средствами LVM.
  2. Изменение корневого раздела:
  - Уменьшить том под / до 8G.
  - Выделить том под /home.
  - Выделить том под /var - сделать в mirror.
  - /home - сделать том для снапшотов.
  - Прописать монтирование в fstab.
  - Попробовать с разными опциями и разными файловыми системами (на выбор).
  3. Работа со снапшотами:
  - сгенерить файлы в /home/;
  - снять снапшот;
  - удалить часть файлов;
  - восстановится со снапшота.
  * На дисках попробовать поставить btrfs/zfs \
    — с кэшем, снапшотами и разметить там каталог /opt.

## 1. Тестовое задание.
   
 - Исходная ситуация с дисками: 
 
```
sudo lsblk
```

![01](./screenshots/01.png)

```
# устанавливаем необходимый пакет
sudo yum install -y lvm2
sudo lvmdiskscan
``` 

![02](./screenshots/02.png)

- Создаем LVG с двумя разделами

```
# определяем переменную BASEDISK = /dev/sdb
BASEDISK=$(sudo lsblk | grep 10G | grep disk | awk '{print "/dev/"$1}')
# создаём LVG otus на устройстве /dev/sdb
sudo pvcreate $BASEDISK
sudo vgcreate otus $BASEDISK
# создаем 2 лог. раздела: /dev/otus/test и /dev/otus/small
sudo lvcreate -l+80%FREE -n test otus
sudo lvcreate -L100M -n small otus
# создаём ФС xfs на /dev/otus/test и монтируем в ~/data/
sudo mkfs.xfs /dev/otus/test
mkdir /home/vagrant/data
sudo mount /dev/otus/test /home/vagrant/data/
sudo chown -R vagrant:vagrant /home/vagrant/data
```

Проверяем, что всё верно: смотрим информацию о ```volume groups```, \
```physical volumes``` и ```logical volumes```:

```
sudo vgdisplay  | grep -i ' name'
sudo vgdisplay -v | grep -i 'pv name'
sudo vgdisplay -v | grep -i 'lv name'
```

![03](./screenshots/03.png)

- Расширим LV ```/dev/otus/test``` за счет добавления диска в LVM

```
#  определяем переменную SNAPDISK = /dev/sdc
SNAPDISK=$(sudo lsblk | grep 2G | grep disk | awk '{print "/dev/"$1}' )
# расширяем LVG за счёт /dev/sdc
sudo pvcreate $SNAPDISK
sudo vgextend otus $SNAPDISK
# занимаем всё место на /dev/otus/test
dd if=/dev/random of=/home/vagrant/data/test.log \
    bs=1M count=8000 status=progress
```


```
# расширяем том /dev/otus/test
sudo lvextend -l+80%FREE /dev/otus/test
sudo resize2fs /dev/otus/test
```


```
# уменьшаем /dev/otus/test
sudo umount /dev/otus/test
sudo e2fsck -fy /dev/otus/test
sudo resize2fs /dev/otus/test 10G
sudo lvreduce -y /dev/otus/test -L 10G
sudo mount /dev/otus/test /home/vagrant/data/
sudo chown -R vagrant:vagrant /home/vagrant/data
```

```
#создаём снапшот
sudo lvcreate -L 500M -s -n test-snap /dev/otus/test
# монтируем и размонтируем снапшот
mkdir /home/vagrant/data-snap
sudo mount /dev/otus/test-snap /home/vagrant/data-snap/
sudo chown -R vagrant:vagrant /home/vagrant/data-snap
sudo umount /home/vagrant/data-snap
```

```
# восстанавливаемся со снапшота
sudo umount /home/vagrant/data
sudo lvconvert --merge /dev/otus/test-snap
sudo mount /dev/otus/test /home/vagrant/data
sudo chown -R vagrant:vagrant /home/vagrant/data-snap

```

```
# /dev/sdd /dev/sde
MIRRORDISKS=$(sudo lsblk | grep 1G | grep disk | awk '{print "/dev/"$1}')
# создаём RAID
sudo pvcreate $MIRRORDISKS
sudo vgcreate vg0 $MIRRORDISKS
sudo lvcreate -l+80%FREE -m1 -n mirror vg0
```

***после перезагрузки***

```
# удаляем lvs
sudo umount /home/vagrant/data
sudo vgremove -f vg0
sudo vgremove -f otus
```


## 2. Обновляем ядро OC на более новую поддерживаемую весию (Almalinux 8.0)

