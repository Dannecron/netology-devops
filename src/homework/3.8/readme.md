Выполнение [домашнего задания](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/03-sysadmin-08-net/README.md) 
по теме "3.8. Компьютерные сети, лекция 3".

## Q/A

1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP

```shell
telnet route-views.routeviews.org
Trying 128.223.51.103...
Connected to route-views.routeviews.org.

<...>

User Access Verification

Username: rviews

route-views>show ip route 46.181.144.146
Routing entry for 46.180.0.0/15
  Known via "bgp 6447", distance 20, metric 0
  Tag 6939, type external
  Last update from 64.71.137.241 7w0d ago
  Routing Descriptor Blocks:
  * 64.71.137.241, from 64.71.137.241, 7w0d ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 6939
      MPLS label: none

route-views>show bgp 46.181.144.146   
BGP routing table entry for 46.180.0.0/15, version 150820343
Paths: (23 available, best #22, table default)
  Not advertised to any peer
  Refresh Epoch 1
  3333 31133 39927, (aggregated by 65423 192.168.21.211)
    193.0.0.56 from 193.0.0.56 (193.0.0.56)
      Origin IGP, localpref 100, valid, external, atomic-aggregate
      path 7FE1040964D8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  8283 1299 39927, (aggregated by 65423 192.168.21.136)
    94.142.247.3 from 94.142.247.3 (94.142.247.3)
      Origin IGP, metric 0, localpref 100, valid, external, atomic-aggregate
      Community: 1299:30000 8283:1 8283:101
      unknown transitive attribute: flag 0xE0 type 0x20 length 0x18
        value 0000 205B 0000 0000 0000 0001 0000 205B
              0000 0005 0000 0001 
      path 7FE0A25887D8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  4901 6079 31133 39927, (aggregated by 65423 192.168.21.211)
    162.250.137.254 from 162.250.137.254 (162.250.137.254)
      Origin IGP, localpref 100, valid, external, atomic-aggregate
      Community: 65000:10100 65000:10300 65000:10400
      path 7FE154880220 RPKI State not found
      rx pathid: 0, tx pathid: 0
<...>
```

2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.

Создание dummy-интерфейса:

```shell
echo "dummy" | sudo tee -a /etc/modules
sudo touch /etc/modprobe.d/dummy.conf
echo "options dummy numdummies=1" | sudo tee /etc/modprobe.d/dummy.conf
sudo ip link add dummy0 type dummy
```

Добавление маршрутов и вывод таблицы маршрутизации:

```shell
sudo ip route add 10.2.2.2/32 dev eth0
sudo ip route add 10.2.2.3/32 via 10.0.2.16
ip route
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100 
10.2.2.2 dev eth0 scope link 
10.2.2.3 via 10.0.2.16 dev eth0
```

3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.

Для вывода открытых TCP-портов используем утилиту `ss` со следующими флагами:
* `-t` вывод только TCP-портов
* `-l` вывод портов в состоянии `LISTEN`, то есть открытые для прослушивания
* `-n` использовать числовое представление портов (например, `:ssh` -> `:22`)
* 

```shell
ss -tln
State                        Recv-Q                       Send-Q                                             Local Address:Port                                               Peer Address:Port                       Process                       
LISTEN                       0                            4096                                               127.0.0.53%lo:53                                                      0.0.0.0:*                                                        
LISTEN                       0                            128                                                      0.0.0.0:22                                                      0.0.0.0:*                                                        
LISTEN                       0                            128                                                         [::]:22                                                         [::]:*                                                                                
```

В данном случае открыты только порты для соединения по `ssh` (порты `:22`) и для [`systemd-resolved`](https://www.freedesktop.org/software/systemd/man/systemd-resolved.service.html) (порт `:53`).

4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?

По аналогии с предыдущим заданием используем утилиту `ss`, заменив флаг `-t` на `-u`

```shell
ss -ulpn
State                        Recv-Q                       Send-Q                                              Local Address:Port                                              Peer Address:Port                       Process                       
UNCONN                       0                            0                                                   127.0.0.53%lo:53                                                     0.0.0.0:*                                                        
UNCONN                       0                            0                                                  10.0.2.15%eth0:68                                                     0.0.0.0:*
```

Порт `:53` предназначается для использования [`systemd-resolved`](https://www.freedesktop.org/software/systemd/man/systemd-resolved.service.html),
а порт `68` используется для получения информации о динамической IP-адресации от DHCP-сервера.

5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали.

В качестве сети взята стандартная домашняя сеть с wi-fi-роутером.

Файл [network.xml](./network.xml) для открытия в [diagrams.net](https://diagrams.net).

![network.png](./network.png)