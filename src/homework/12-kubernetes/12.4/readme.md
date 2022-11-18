Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/12-kubernetes-04-install-part-2.md)
по теме "12.4. Развертывание кластера на собственных серверах, лекция 2"

## Q/A

> Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив.
> Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

### Задание 1

> Подготовить инвентарь kubespray
> 
> Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
> * подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
> * в качестве CRI — containerd;
> * запуск etcd производить на мастере.

Пример inventory-файла для запуска `kubespray`: [`inventory.example.ini`](./kubespray/inventory.example.ini).
В данной конфигурации необходимо только изменить ip-адреса виртуальных машин.

### Задание 2

> Подготовить и проверить инвентарь для кластера в yandex.cloud
> 
> Часть новых проектов хотят запускать на мощностях yandex.cloud. Требования похожи:
> * разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
> * работать должны на минимально допустимых виртуальных машинах 

Для деплоя виртуальных машин в yandex.cloud написана конфигурация [terraform](./terraform/main.tf). Для запуска процесса необходимо:
* скопировать [variables.tf.example](./terraform/variables.tf.example) в [variables.tf](./terraform/variables.tf)
  и проставить необходимые значения (для создания нового токена можно использовать команду `yc iam create-token`)
* просмотреть шаги, которые будут сделаны 

    ```shell
    terraform plan
    ```

* применить конфигурацию

    ```shell
    terraform apply
    ```

__Note:__ более подробно про terraform описано в домашних заданиях [5.4](/src/homework/05-virtualization/5.4) и [7.x](/src/homework/07-terraform).

После выполнения в блоке `outputs` будут выведены ip-адреса созданных машин:

```text
Outputs:

control_ips = {
  "external" = "62.84.124.154"
  "internal" = "192.168.10.12"
}
node_ips = {
  "external" = [
    "62.84.124.232",
    "51.250.81.132",
    "84.201.130.174",
    "62.84.127.45",
  ]
  "internal" = [
    "192.168.10.3",
    "192.168.10.10",
    "192.168.10.18",
    "192.168.10.15",
  ]
}
```

В конфигурацию [kubespray](./kubespray/inventory.example.ini) нужно поставить значения:

* в `control ansible_host` значение `control_ips.external`
* в значения нод `ansibe_host` значения из `node_ips.external`

Следующим шагом будет непосредственный запуск `kubespray` (из корневой директории репозитория):

```shell
ansible-playbook -u ubuntu -i inventory/mycluster/inventory.ini cluster.yml -b -v
```

После успешной установки необходимо подключиться по ssh к ноде `control` и настроить `kubectl`:

```shell
ssh ubuntu@62.84.124.154
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config
```

После данных действий через `kubectl` возможно выполнять команды в созданном кластере.

```shell
kubectl get namespaces
```

```text
NAME              STATUS   AGE
default           Active   10m
kube-node-lease   Active   10m
kube-public       Active   10m
kube-system       Active   10m
```

```shell
kubectl get pods --namespace=kube-system
```

```text
NAME                              READY   STATUS    RESTARTS       AGE
calico-node-9g626                 1/1     Running   0              10m
calico-node-9v8h5                 1/1     Running   0              10m
calico-node-fnlxc                 1/1     Running   0              10m
calico-node-pwxmx                 1/1     Running   0              10m
calico-node-vfzpk                 1/1     Running   0              10m
<...>
```

А так же можно развернуть новый деплоймент (например, [hello_node_deployment.yml](/src/homework/12-kubernetes/12.2/config/hello_node_deployment.yml) из домашнего задания 12.2)

```shell
kubectl apply hello_node_deployment.yml
kubectl get deployments
kubectl get pods
```

```text
deployment.apps/hello-node-deployment created

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
hello-node-deployment   4/4     4            4           14s

NAME                                     READY   STATUS    RESTARTS   AGE
hello-node-deployment-7484fdb5bb-8fpf7   1/1     Running   0          16s
hello-node-deployment-7484fdb5bb-mmzr5   1/1     Running   0          16s
hello-node-deployment-7484fdb5bb-tvd4v   1/1     Running   0          16s
hello-node-deployment-7484fdb5bb-wbf5z   1/1     Running   0          16s
```
