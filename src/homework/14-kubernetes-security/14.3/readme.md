Выполнение [домашнего задания](https://github.com/netology-code/clokub-homeworks/blob/clokub-5/14.3.md)
по теме "14.3. Карты конфигураций"

## Q/A

### Задача 1

> Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
> задачу 1 как справочный материал.

> #### Как создать карту конфигураций?
> 
> ```
> kubectl create configmap nginx-config --from-file=config/nginx.conf
> kubectl create configmap domain --from-literal=name=netology.ru
> ```

```text
configmap/nginx-config created
configmap/domain created
```

> #### Как просмотреть список карт конфигураций?
> 
> ```
> kubectl get configmap
> ```

```text
NAME               DATA   AGE
domain             1      15s
kube-root-ca.crt   1      8m25s
nginx-config       1      27s
```

> #### Как просмотреть карту конфигурации?
> 
> ```
> kubectl get configmap nginx-config
> kubectl describe configmap domain
> ```

```text
NAME           DATA   AGE
nginx-config   1      39s
```

```text
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>
```

> #### Как получить информацию в формате YAML и/или JSON?
> 
> ```
> kubectl get configmap nginx-config -o yaml
> kubectl get configmap domain -o json
> ```

```yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-12-29T03:11:21Z"
  name: nginx-config
  namespace: default
  resourceVersion: "703"
  uid: 8dfa9f4c-6d89-4fbf-b3f6-1cd87b16710b
```

```json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-12-29T03:11:33Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "712",
        "uid": "2e6bb329-e5f9-42c5-80d1-b8624b7f9a67"
    }
}
```

> #### Как выгрузить карту конфигурации и сохранить его в файл?
> 
> ```
> kubectl get configmaps -o json > config/configmaps.json
> kubectl get configmap nginx-config -o yaml > config/nginx-config.yml
> ```

Файлы:
* [configmaps.json](./config/configmaps.json)
* [nginx-config.yml](./config/nginx-config.yml)

> #### Как удалить карту конфигурации?
> 
> ```
> kubectl delete configmap nginx-config
> ```

```text
configmap "nginx-config" deleted
```

> ### Как загрузить карту конфигурации из файла?
> 
> ```
> kubectl apply -f config/nginx-config.yml
> ```

```text
configmap/nginx-config created
```

### Задача 2

> Выбрать любимый образ контейнера, подключить карты конфигураций и проверить
> их доступность как в виде переменных окружения, так и в виде примонтированного
> тома.

За основу будет взят образ `praqma/network-multitool`. В рамках конфигурации [test_pod.yml](./config/test_pod.yml)
описаны два `ConfigMap`: один для значений переменных окружения, второй - для файла. Затем они используются в рамках
конфигурации пода.

Применение конфигурации:

```shell
kubectl apply -f config/test_pod.yml
kubectl get pods
```

```text
configmap/test-env-config created
configmap/test-file-config created
pod/test-pod created

NAME       READY   STATUS    RESTARTS   AGE
test-pod   1/1     Running   0          21s
```

Проверка, что переменные окружения присутствуют в контейнере:

```shell
kubectl exec -it pod/test-pod -- printenv | grep SOME
```

```shell
SOME_PASSWORD=passwd
SOME_USER=user
SOME_NGINX_USER=user
```

Проверка, что успешно создан файл по `ConfigMap` внутри контейнера:

```shell
kubectl exec -it pod/test-pod -- ls -la /opt/config
```

```text
total 12
drwxrwxrwx    3 root     root          4096 Dec 29 03:23 .
drwxr-xr-x    1 root     root          4096 Dec 29 03:23 ..
drwxr-xr-x    2 root     root          4096 Dec 29 03:23 ..2022_12_29_03_23_06.2057404337
lrwxrwxrwx    1 root     root            32 Dec 29 03:23 ..data -> ..2022_12_29_03_23_06.2057404337
lrwxrwxrwx    1 root     root            15 Dec 29 03:23 foo.json -> ..data/foo.json
```

```shell
kubectl exec -it pod/test-pod -- cat /opt/config/foo.json
```

```text
{"foo": "bar", "baz": 123}
```
