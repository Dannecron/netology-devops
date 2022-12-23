Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/13-kubernetes-config-02-mounts.md)
по теме "13.2. разделы и монтирование"

## Q/A

> Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные.
> А сам бекенд генерирует статику для фронта. Нужно оптимизировать это. 
> Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
> 
> * установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
> * добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
> * установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner
> 
> В конце установки будет выдан пример создания PVC для этого сервера.

### Задание 1

> В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
> * в поде подключена общая папка между контейнерами (например, /static);
> * после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

Для деплоя приложения будет использована [спецификация из предыдущего домашнего задания](/src/homework/13-kubernetes-config/13.1/config/testing) с некоторыми отличиями:

1. В deployment `testing-app` добавлен том `emptyDir` с названием `shared-volume`
    
    ```yaml
    volumes:
      - name: test-shared-volume
        emptyDir: {}
    ```    

2. В контейнеры `netology-frontend` и `netology-backend` добавлена точка монтирования в `/static` для данного тома
   
    ```yaml
    volumeMounts:
      - mountPath: "/static"
        name: test-shared-volume
    ```

Итоговая конфигурация расположена в файле [testing/deployment.yml](./config/testing/deployment.yml).

Применение конфигурации:

```shell
kubectl apply -f testing/deployment.yml
```

Чтобы проверить, что файлы, созданные в одном контейнере будут видны в другом, нужно выполнить следующие шаги:

* Записать данные в новый файл `/static/42.txt`

    ```shell
    kubectl exec testing-app-85d8f9d7bc-x5cbm -c netology-backend -- sh -c "echo '42' > /static/42.txt"
    ```

* Проверить, что файл доступен из данного контейнера

    ```shell
    kubectl exec testing-app-85d8f9d7bc-x5cbm -c netology-backend -- sh -c "cat /static/42.txt"
    ```
  
    ```text
    42
    ```

* Проверить, что файл доступен из другого контейнера

    ```shell
    kubectl exec testing-app-85d8f9d7bc-x5cbm -c netology-frontend -- sh -c "cat /static/42.txt"
    ```
  
    ```text
    42
    ```

### Задание 2

> Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
> * все бекенды подключаются к одному PV в режиме ReadWriteMany;
> * фронтенды тоже подключаются к этому же PV с таким же режимом;
> * файлы, созданные бекендом, должны быть доступны фронту.

Перед выполнением задания необходимо установить плагин `nfs`, для этого:

* Необходимо установить `helm`:

    ```shell
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    helm version
    ```

    ```text
    version.BuildInfo{Version:"v3.10.2", GitCommit:"50f003e5ee8704ec937a756c646870227d7c8b58", GitTreeState:"clean", GoVersion:"go1.18.8"}
    ```

* Добавить основной репозиторий `helm`

    ```shell
    helm repo add stable https://charts.helm.sh/stable && helm repo update
    ```

* Установить `nfs`-сервер

    ```shell
    helm install nfs-server stable/nfs-server-provisioner
    ```

* Установить на всех нодах необходимую утилиту:

    ```shell
    sudo apt install nfs-common
    ```

Для деплоя приложения будет использована [спецификация из предыдущего домашнего задания](/src/homework/13-kubernetes-config/13.1/config/production) с некоторыми отличиями:

1. Создан отдельный манифест для создания общего динамичного хранилища: [production/volume.yml](./config/production/volume.yml)
2. В deployment для `backend` и `frontend` добавлен том `shared-volume` и точка его монтирования в `/shared` 

Порядок деплоя:

* Создание динамичного `pvc`

    ```shell
    kubectl apply -f production/volume.yml
    kubectl get pvc
    ```

    ```text
    NAME   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    pvc    Bound    pvc-fd56d76a-a856-41e6-90a6-8ee4ca1a6439   1Gi        RWO            nfs            7s
    ```

* Деплой БД: `kubectl apply -f production/database.yml`
* Деплой backend: `kubectl apply -f production/backend.yml`
* Деплой frontend: `kubectl apply -f production/frontend.yml`
* Проверка, что всё работает:

    ```shell
    kubectl get pods
    ```
    
    ```text
    NAME                                  READY   STATUS    RESTARTS   AGE
    nfs-server-nfs-server-provisioner-0   1/1     Running   0          10m
    prod-app-backend-755859df77-lcst2     1/1     Running   0          26s
    prod-app-frontend-5967548577-dvzxc    1/1     Running   0          18s
    testing-db-0                          1/1     Running   0          5m58s
    ```

Чтобы проверить, что файлы, созданные в одном поде будут видны в другом, нужно выполнить следующие шаги:

* Записать данные в новый файл `/shared/42.txt`

    ```shell
    kubectl exec prod-app-backend-755859df77-lcst2 -c netology-backend -- sh -c "echo '42' > /shared/42.txt"
    ```

* Проверить, что файл доступен из данного пода

    ```shell
    kubectl exec prod-app-backend-755859df77-lcst2 -c netology-backend -- sh -c "cat /shared/42.txt"
    ```

    ```text
    42
    ```

* Проверить, что файл доступен из другого пода

    ```shell
    kubectl exec prod-app-frontend-5967548577-dvzxc -c netology-frontend -- sh -c "cat /shared/42.txt"
    ```

    ```text
    42
    ```
