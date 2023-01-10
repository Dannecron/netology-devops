Выполнение [домашнего задания](https://github.com/netology-code/clokub-homeworks/blob/clokub-5/14.4.md)
по теме "14.4. Сервис-аккаунты"

## Q/A

### Задача 1

> Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube.
> 
> #### Как создать сервис-аккаунт?
> 
> ```
> kubectl create serviceaccount netology
> ```

```text
serviceaccount/netology created
```

> #### Как просмотреть список сервис-акаунтов?
> 
> ```
> kubectl get serviceaccounts
> ```

```text
AME       SECRETS   AGE
default    0         16m
netology   0         16s
```

> #### Как получить информацию в формате YAML и/или JSON?
> 
> ```
> kubectl get serviceaccount netology -o yaml
> kubectl get serviceaccount default -o json
> ```

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2023-01-10T02:49:45Z"
  name: netology
  namespace: default
  resourceVersion: "2173"
  uid: 84e1eeb6-7f11-469f-8d90-3dd24ceb1a4c
```

```json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2023-01-10T02:33:23Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "325",
        "uid": "ed1a01af-98a5-412f-a726-57540bf11255"
    }
}
```

> #### Как выгрузить сервис-акаунты и сохранить его в файл?
> 
> ```
> kubectl get serviceaccounts -o json > config/serviceaccounts.json
> kubectl get serviceaccount netology -o yaml > config/netology.yml
> ```

После выполнения команд созданы два файла:
* [netology.yml](./config/netology.yml)
* [serviceaccounts.json](./config/serviceaccounts.json)

> #### Как удалить сервис-акаунт?
> 
> ```
> kubectl delete serviceaccount netology
> ```

```text
serviceaccount "netology" deleted
```

> #### Как загрузить сервис-акаунт из файла?
> 
> ```
> kubectl apply -f config/netology.yml
> ```

```text
serviceaccount/netology created
```

### Задание 2

> Работа с сервис-акаунтами внутри модуля.
> 
> Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить
> доступность API Kubernetes
> 
> ```
> kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
> ```
> 
> Просмотреть переменные среды
> 
> ```
> env | grep KUBE
> ```

```text
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
KUBERNETES_SERVICE_HOST=10.233.0.1
KUBERNETES_PORT=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
```

> Получить значения переменных
> 
> ```
> K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
> SADIR=/var/run/secrets/kubernetes.io/serviceaccount
> TOKEN=$(cat $SADIR/token)
> CACERT=$SADIR/ca.crt
> NAMESPACE=$(cat $SADIR/namespace)
> ```
> 
> Подключаемся к API
> 
> ```
> curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
> ```
> 
> В случае с minikube может быть другой адрес и порт, который можно взять здесь
> 
> ```
> cat ~/.kube/config
> ```
> 
> или здесь
> 
> ```
> kubectl cluster-info
> ```

Ответ на запрос к api kubernetes: 

```json
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    "..."
  ]
}
```
