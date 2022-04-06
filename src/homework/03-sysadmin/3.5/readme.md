Выполнение [домашнего задания](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/03-sysadmin-05-fs/README.md) 
по теме "3.5. Файловые системы".

## Q/A

1. Разряженные файлы

Суть таких файлов в том, чтобы разделить реальные данные последовательностью нуль-символов (`\x00`), которые не занимают реального места на физическом носителе.
При этом сами данные записываются на разных фрагментах на физическом диске. 

Например, если есть разряжённый файл размером в 4KB, то он может быть поделён на 4 блока по 1KB и записан на диск именно такими фрагментами.
Это позволяет сделать запись туда, где доступно 1-2KB (например, после удаления другого файла),
но куда оригинальный файл целиком не поместится.

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Не могут. Причина в том, что жёсткие ссылки всегда ссылаются на одну `Inode` (идентификатор объекта файла внутри ОС).
То есть, все файлы, которые имеют одну `Inode` будут синхронизированы по: содержимому, правам доступа и другим мета-данным.

3. Реконфигурация виртуальной машины

В текущую конфигурацию [`vagrant`](/src/vagrant/Vagrantfile) добавлена конфигурация дисков:

```
config.vm.provider :virtualbox do |vb|
  lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
  lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
  vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
  vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
  vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
  vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
end
```

После запуска ВМ (`vagrant up`) можно проверить, что файлы дисков из конфигурации были созданы:

```shell
ls /tmp | grep lvm
lvm_experiments_disk0.vmdk
lvm_experiments_disk1.vmdk
```

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

Найдём диски, которые были подключены на предыдущем шаге

```shell
sudo fdisk -l

<...>

Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

<...>
```

Проведём операцию на диске `/dev/sdb`. Утилита `fdisk` - интерактивная, поэтому вводить команды нужно непосредственно после её запуска.

```shell
sudo fdisk /dev/sdb

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x0c6b10a9.

Command (m for help): g
Created a new GPT disklabel (GUID: F75C9D4B-5A47-7540-8A8D-D7448C95BCE5).

Command (m for help): n
Partition number (1-128, default 1): 1
First sector (2048-5242846, default 2048): 2048
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242846, default 5242846): +2G

Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.

Command (m for help): n
Partition number (2-128, default 2): 2
First sector (4196352-5242846, default 4196352): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242846, default 5242846): 

Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

Проверим, что всё прошло успешно

```shell
sudo fdisk -l /dev/sdb
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: F75C9D4B-5A47-7540-8A8D-D7448C95BCE5

Device       Start     End Sectors  Size Type
/dev/sdb1     2048 4196351 4194304    2G Linux filesystem
/dev/sdb2  4196352 5242846 1046495  511M Linux filesystem
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

Перенесём таблицу разделов с `/dev/sdb` на `/dev/sdc`.

```shell
sudo sfdisk --dump /dev/sdb > /tmp/sdb.dump

sudo sfdisk /dev/sdc < /tmp/sdb.dump

Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new GPT disklabel (GUID: F75C9D4B-5A47-7540-8A8D-D7448C95BCE5).
/dev/sdc1: Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: gpt
Disk identifier: F75C9D4B-5A47-7540-8A8D-D7448C95BCE5

Device       Start     End Sectors  Size Type
/dev/sdc1     2048 4196351 4194304    2G Linux filesystem
/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

Проверим, что всё прошло успешно

```shell
sudo fdisk -l /dev/sdc
Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: F75C9D4B-5A47-7540-8A8D-D7448C95BCE5

Device       Start     End Sectors  Size Type
/dev/sdc1     2048 4196351 4194304    2G Linux filesystem
/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem
```

6. Соберите `mdadm` `RAID1` на паре разделов 2 Гб.

Разделы, которые необходимо объединить в `RAID1`: `/dev/sdb1` и `/dev/sdc1`.

```shell
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

7. Соберите `mdadm` `RAID0` на второй паре маленьких разделов

Разделы, которые необходимо объединить в `RAID0`: `/dev/sdb2` и `/dev/sdc2`.

```shell
sudo mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```

8. Создайте 2 независимых PV на получившихся md-устройствах

```shell
sudo pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
sudo pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.

sudo pvdisplay
"/dev/md0" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md0
  VG Name               
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               hNpE2z-h7m3-W1HT-dBIh-Xm24-6Zal-dhtPfl
   
  "/dev/md1" is a new physical volume of "1017.00 MiB"
  --- NEW Physical volume ---
  PV Name               /dev/md1
  VG Name               
  PV Size               1017.00 MiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               PB8hEQ-bZGA-M6Xe-tOQV-1CAb-DRSf-syoUSA
```

9. Создайте общую volume-group на этих двух PV.

```shell
sudo vgcreate test_vg /dev/md0 /dev/md1
  Volume group "test_vg" successfully created

sudo vgdisplay
--- Volume group ---
  VG Name               test_vg
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0   
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               7xcN3Z-o9Ca-iXl2-5eao-iA4e-cEVJ-YgSajr
```

10. Создайте LV размером 100 Мб, указав его расположение на PV с `RAID0`.

```shell
sudo lvcreate --size=100MB test_vg /dev/md1
  Logical volume "lvol0" created.
  
sudo lvdisplay
--- Logical volume ---
  LV Path                /dev/test_vg/lvol0
  LV Name                lvol0
  VG Name                test_vg
  LV UUID                1fJJLO-zJeY-924D-O9gn-N1Cz-fyQ6-mnA7Z3
  LV Write Access        read/write
  LV Creation host, time vagrant, 2022-03-02 02:55:17 +0000
  LV Status              available
  # open                 0
  LV Size                100.00 MiB
  Current LE             25
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:1
```

11. Создайте `mkfs.ext4` ФС на получившемся `LV`

```shell
sudo mkfs.ext4 /dev/test_vg/lvol0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

12. Смонтируйте этот раздел в любую директорию.

```shell
mkdir /tmp/new
sudo mount /dev/test_vg/lvol0 /tmp/new
```

13. Поместите туда тестовый файл.

```shell
sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz

--2022-03-02 03:04:07--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22388361 (21M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’ 

2022-03-02 03:04:09 (9.33 MB/s) - ‘/tmp/new/test.gz’ saved [22388361/22388361]
```

14. Прикрепите вывод `lsblk`.

```shell
sudo lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 55.4M  1 loop  /snap/core18/2128
loop2                       7:2    0 70.3M  1 loop  /snap/lxd/21029
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2284
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/14978
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1361
loop6                       7:6    0 67.9M  1 loop  /snap/lxd/22526
sda                         8:0    0   64G  0 disk  
├─sda1                      8:1    0    1M  0 part  
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part  
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk  
├─sdb1                      8:17   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdb2                      8:18   0  511M  0 part  
  └─md1                     9:1    0 1017M  0 raid0 
    └─test_vg-lvol0       253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk  
├─sdc1                      8:33   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdc2                      8:34   0  511M  0 part  
  └─md1                     9:1    0 1017M  0 raid0 
    └─test_vg-lvol0       253:1    0  100M  0 lvm   /tmp/new
```

15. Протестируйте целостность файла

```shell
sudo gzip -t /tmp/new/test.gz
echo $?

0
```

16. Используя `pvmove`, переместите содержимое PV с `RAID0` на `RAID1`.

```shell
sudo pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 16.00%
  /dev/md1: Moved: 100.00%
```

17. Сделайте `--fail` на устройство в вашем `RAID1` md.

```shell
sudo mdadm --fail /dev/md0 /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```

18. Подтвердите выводом `dmesg`, что `RAID1` работает в деградированном состоянии

```shell
sudo dmesg | tail -n 5
[ 2711.025093] 02:44:35.853387 timesync vgsvcTimeSyncWorker: Radical guest time change: 81 954 170 807 000ns (GuestNow=1 646 189 075 853 355 000 ns GuestLast=1 646 107 121 682 548 000 ns fSetTimeLastLoop=true )
[ 3814.237420] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[ 3814.237429] ext4 filesystem being mounted at /tmp/new supports timestamps until 2038 (0x7fffffff)
[ 4328.371203] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен

```shell
sudo gzip -t /tmp/new/test.gz
echo $?
0
```