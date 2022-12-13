Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/13-kubernetes-config-03-kubectl.md)
по теме "13.3. работа с kubectl"

## Q/A

### Задание 1

> Проверить работоспособность каждого компонента.
> 
> Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
> * сделайте запросы к бекенду;
> * сделайте запросы к фронту;
> * подключитесь к базе данных.

За основу будут взяты [манифесты из домашнего задания 13.1](/src/homework/13-kubernates-config/13.1/config/production) 
для production-окружения.

Перед применением необходимо сделать так, чтобы в кластер было возможно сделать запросы с локальной машины.
Для этого необходимо в inventory-конфигурации `kubespray` в файле `group_vars/k8s_cluster/k8s-cluster.yml` изменить значение
ключа `supplementary_addresses_in_ssl_keys` на массив, состоящий из одного внешнего ip-адреса `control-node`:

```yaml
supplementary_addresses_in_ssl_keys: [51.250.6.171]
```

И затем запустить установку и настройку кластера. Подробнее об этом в [домашнем задании 12.4](/src/homework/12-kubernetes/12.4/readme.md).

Затем, необходимо скопировать с `control-node` файл `~/.kube/config` (который предварительно должен быть туда скопирован) на локальную машину и изменить
значение ключа `server` на внешний ip-адрес `control-node`.

```shell
scp ubuntu@51.250.6.171:/home/ubuntu/.kube/config ~/.kube/kubespray-do.conf
```

Затем нужно установить данный конфиг для `kubectl` для текущей сессии терминала и выполнить проверку доступности кластера:

```shell
export KUBECONFIG=~/.kube/kubespray-do.conf
kubectl get pods -A
```

```text
NAMESPACE     NAME                              READY   STATUS    RESTARTS      AGE
kube-system   calico-node-mxl5c                 1/1     Running   0             22m
kube-system   calico-node-tfz88                 1/1     Running   0             22m
kube-system   coredns-74d6c5659f-l2hfb          1/1     Running   0             20m
<...>
```

Для подключения к базе данных необходимо запустить `port-forward` на локальной машине к сервису `postgresql`:

```shell
kubectl port-forward service/postgres 5432:5432
```

```text
Forwarding from 127.0.0.1:5432 -> 5432
Forwarding from [::1]:5432 -> 5432
```

Не закрывая данную сессию терминала нужно выполнить запуск контейнера `postgresql` с утилитой `psql` в качестве входной точки:

```shell
docker run --rm -it --network=host --entrypoint=/bin/sh postgres:13-alpine -c "psql postgresql://db_user:db_passwd@localhost:5432/news"
```

В этом случае будет инициировано подключение к проброшенному порту на локальной машине без необходимости дополнительно конфигурировать
сети docker-контейнеров. Следующим шагом можно проверить, что пользователю видны таблицы из БД:

```text
news=# \d
```

```text
             List of relations
 Schema |    Name     |   Type   |  Owner
--------+-------------+----------+---------
 public | news        | table    | db_user
 public | news_id_seq | sequence | db_user
(2 rows)
```

// todo frontend and backend

### Задание 2

> Ручное масштабирование.
> 
> При работе с приложением иногда может потребоваться вручную добавить пару копий.
> Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3.
> Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

// todo
