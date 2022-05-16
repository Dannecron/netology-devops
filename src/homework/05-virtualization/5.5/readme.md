Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/virt-11/05-virt-05-docker-swarm/README.md) 
по теме "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm".

## Q/A

### Задача 1

> Дайте письменные ответы на следующие вопросы:

> - В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?

В режиме `replication` для сервиса указывается количество реплик, которые необходимо запустить.
И именно такое количество копий сервиса будет запущено, не зависимо от количества нод в кластере.
    
В режиме `global` указанный сервис будет запущен на каждой ноде кластера. При этом невозможно указать конкретное количество реплик.

> - Какой алгоритм выбора лидера используется в Docker Swarm кластере?

Для выбора лидера docker swarm использует алгоритм поддержания распределенного консенсуса — [`Raft`](https://raft.github.io/).

Верхне-уровневый принцип работы `Raft` (основано на [примере](http://thesecretlivesofdata.com/raft/)):

- Каждая нода может находиться в одном из 3-х состояний: `Follower`, `Candidate`, `Leader`.
- В начале работы кластера все ноды находятся в состоянии `Follower`.
- Если нода в состоянии `Follower` не получает информации от `Leader`, то она переходит в состояние `Candidate`.
- После перехода в состояние `Candidate` нода запрашивает "голосование" от других нод кластера.
- Ноды отвечают на опрос кандидату, который инициировал голосование. Если данный кандидат получил большинство положительных ответов, то он переходит в состояние `Leader`.

> - Что такое Overlay Network?

`Overlay Network` - это особый тип docker-сети, который позволяет связать контейнеры, запущенные на разных нодах. 
То есть, данная сеть позволяет направить трафик на определённый контейнер на определённой ноде только по имени контейнера.

### Задача 2

> Создать ваш первый Docker Swarm кластер в Яндекс.Облаке
>
> Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
>
> ```shell
> docker node ls
> ```

Для начала необходимо выполнить шаги создания образа ОС в облаке, следуя инструкции из домашней работы [5.4](/src/homework/05-virtualization/5.4/readme.md#Задача 1).

После того как образ будет создан:
1. Скопировать секреты для `terraform` из [variables.tf.example](./terraform/variables.tf.example) в `variables.tf`
2. Затем нужно изменить поля в конфигурации.
3. Инициализировать конфигурацию: `terraform init` (не работает без vpn, при получении данных отдаётся 403 статус код)
4. Просмотреть конфигурацию `terraform plan`
5. Применить конфигурацию к облаку `terraform apply -auto-approve`
6. Подключится по ssh к машине, чей ip-адрес будет выведен в строке с переменной `external_ip_address_node01` и выполнить необходимую команду:
   ```shell
   ssh centos@51.250.64.218
   sudo docker node ls
   ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
   ttj5yee26pppcezlys0g0pzum *   node01.netology.yc   Ready     Active         Leader           20.10.16
   a717bja2genbm7c6prdxailfy     node02.netology.yc   Ready     Active         Reachable        20.10.16
   qijk98huwd1y1omhsphc28rjr     node03.netology.yc   Ready     Active         Reachable        20.10.16
   pbmbmjeawqf7sst6yia40llwp     node04.netology.yc   Ready     Active                          20.10.16
   y6g2mtvdcitnmyzxwnipklk82     node05.netology.yc   Ready     Active                          20.10.16
   s7f1f34ef238lvd7qltftb6jt     node06.netology.yc   Ready     Active                          20.10.16
   ```

### Задача 3

> Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.
>
> Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
>
> ```shell
> docker service ls
> ```

Стэк сервисов был развёрнут в рамках [второго задания](#Задача 2) при запуске `terraform`.

```shell
sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
4iot28xmyl3w   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
5akoz6vjp9a3   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
mf0c8h4vyuue   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
vbgaltbn2t17   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
ihmlsx3bmxs0   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
uju9p0ws4vwm   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
8ipjzv0vax7m   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
96xidxmifhco   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```

Для того, чтобы зайти на web-панель `grafana`, необходимо:
1. Выяснить, на какой ноде был развёрнут данный сервис
   ```shell
   sudo docker service ps swarm_monitoring_grafana
   ID             NAME                         IMAGE                                  NODE                 DESIRED STATE   CURRENT STATE           ERROR     PORTS
   t97g9zhyggja   swarm_monitoring_grafana.1   stefanprodan/swarmprom-grafana:5.3.4   node02.netology.yc   Running         Running 7 minutes ago
   ```
2. Выяснить внешний ip-адрес искомой ноды. Для этого можно посмотреть в [`ansible/inventory`](./ansible/inventory) файл.
   Либо выполнить команду:
   ```shell
   sudo docker inspect node02.netology.yc --format '{{ .Status.Addr  }}'
   192.168.101.12
   ```
3. Зайти по полученному адресу на порт `:3000`: `http://192.168.101.12:3000`.

### Clean up

Удаление всей инфраструктуры:

1. Удаление ВМ, сетей: `terraform destroy -auto-approve`
2. Удаление образа ОС: `yc compute image delete --id {{ image_id }}`