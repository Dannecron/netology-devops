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

Следующим шагом нужно пробросить порт `9000` непосредственно до пода `backend`. Для этого через команду `kubectl get pods` 
необходимо найти название пода (оно уникальное, так как развёртывание было произведено при помощи объекта `Deployment`),
а затем выполнить непосредственно проброс порта:

```shell
kubectl port-forward pods/prod-app-backend-7fd6f4f558-7qvc4 9000:9000
```

```text
Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000
```

Для проверки необходимо выполнить curl-запрос к localhost в отдельной консольной сессии:

```shell
curl http://localhost:9000
```

```text
{"detail":"Not Found"}
```

Для обращения к frontend будет использован метод `exec` и выведено содержимое корневой директории со собранной статикой:

```shell
kubectl exec prod-app-frontend-69bcf947f8-xvdzc -- sh -c "ls -la /app/"
```

```text
total 420
drwxr-xr-x 1 root root   4096 Nov 30 03:33 .
drwxr-xr-x 1 root root   4096 Dec 14 03:22 ..
-rw-r--r-- 1 root root     38 Nov 30 03:33 .env
-rw-r--r-- 1 root root     30 Nov 29 03:49 .env.example
-rw-r--r-- 1 root root    390 Nov 30 02:59 Dockerfile
drwxr-xr-x 2 root root   4096 Nov 30 02:57 build
-rw-r--r-- 1 root root    344 Nov 29 03:49 demo.conf
-rw-r--r-- 1 root root    448 Nov 29 03:49 index.html
-rw-r--r-- 1 root root    344 Nov 29 03:49 item.html
drwxr-xr-x 2 root root   4096 Nov 30 02:57 js
-rw-r--r-- 1 root root     80 Nov 29 03:49 list.json
-rw-r--r-- 1 root root 364679 Nov 29 03:49 package-lock.json
-rw-r--r-- 1 root root   1107 Nov 29 03:49 package.json
drwxr-xr-x 2 root root   4096 Nov 30 02:57 static
drwxr-xr-x 3 root root   4096 Nov 30 02:57 styles
-rw-r--r-- 1 root root   2781 Nov 29 03:49 webpack.config.js
```

### Задание 2

> Ручное масштабирование.
> 
> При работе с приложением иногда может потребоваться вручную добавить пару копий.
> Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3.
> Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide).
> После уменьшите количество копий до 1.

Команды изменения количества реплик до 3-х:

```shell
kubectl scale --replicas=3 deployment/prod-app-backend
kubectl scale --replicas=3 deployment/prod-app-frontend
```

Проверка после выполнения:

```shell
kubectl describe deployments.apps prod-app-backend
```

```text
Name:                   prod-app-backend
Namespace:              default
CreationTimestamp:      Wed, 14 Dec 2022 10:14:32 +0700
Labels:                 app=prod-app
                        service=backend
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=prod-app,service=backend
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=prod-app
           service=backend
  Containers:
   netology-backend:
    Image:      dannecron/netology-devops-k8s-app:backend-latest
    Port:       9000/TCP
    Host Port:  0/TCP
    Environment:
      DATABASE_URL:  postgresql://db_user:db_passwd@postgres:5432/news
    Mounts:          <none>
  Volumes:           <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   prod-app-backend-7fd6f4f558 (3/3 replicas created)
```

```shell
kubectl describe deployments.apps prod-app-frontend
```

```text
Name:                   prod-app-frontend
Namespace:              default
CreationTimestamp:      Wed, 14 Dec 2022 10:22:09 +0700
Labels:                 app=prod-app
                        service=frontend
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=prod-app,service=frontend
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=prod-app
           service=frontend
  Containers:
   netology-frontend:
    Image:      dannecron/netology-devops-k8s-app:frontend-latest
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:
      BASE_URL:  http://prod-backend:9000
    Mounts:      <none>
  Volumes:       <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   prod-app-frontend-69bcf947f8 (3/3 replicas created)
```

```shell
kubectl get pods -o wide
```

```text
NAME                                 READY   STATUS    RESTARTS   AGE     IP               NODE    NOMINATED NODE   READINESS GATES
prod-app-backend-7fd6f4f558-7p64m    1/1     Running   0          3m12s   10.233.102.133   node1   <none>           <none>
prod-app-backend-7fd6f4f558-7qvc4    1/1     Running   0          13m     10.233.102.131   node1   <none>           <none>
prod-app-backend-7fd6f4f558-ctdwg    1/1     Running   0          3m12s   10.233.102.134   node1   <none>           <none>
prod-app-frontend-69bcf947f8-mzdf6   1/1     Running   0          2m45s   10.233.102.136   node1   <none>           <none>
prod-app-frontend-69bcf947f8-pzjk2   1/1     Running   0          2m45s   10.233.102.135   node1   <none>           <none>
prod-app-frontend-69bcf947f8-xvdzc   1/1     Running   0          6m9s    10.233.102.132   node1   <none>           <none>
prod-db-0                            1/1     Running   0          14m     10.233.102.130   node1   <none>           <none>
```

Все поды оказались на одной машине, так как сам кластер состоит только из одной рабочей ноды.

Команды изменения количества реплик до 1-й:

```shell
kubectl scale --replicas=1 deployment/prod-app-backend
kubectl scale --replicas=1 deployment/prod-app-frontend
```

Проверка, что все изменения применились:

```shell
kubectl get pods -o wide
```

```text
NAME                                 READY   STATUS    RESTARTS   AGE     IP               NODE    NOMINATED NODE   READINESS GATES
prod-app-backend-7fd6f4f558-7qvc4    1/1     Running   0          16m     10.233.102.131   node1   <none>           <none>
prod-app-frontend-69bcf947f8-xvdzc   1/1     Running   0          8m27s   10.233.102.132   node1   <none>           <none>
prod-db-0                            1/1     Running   0          16m     10.233.102.130   node1   <none>           <none>
```
