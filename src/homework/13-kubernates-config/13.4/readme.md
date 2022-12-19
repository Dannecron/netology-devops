Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/13-kubernetes-config-04-helm.md)
по теме "13.4. инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"

## Q/A

> В работе часто приходится применять системы автоматической генерации конфигураций.
> Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

### Задание 1

> Подготовить helm чарт для приложения.
>
> Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:
> * каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
> * в переменных чарта измените образ приложения для изменения версии.

Helm-чарт находится в директории [project](./project). Каждый компонент приложения выделен в отдельный шаблон.

Различные переменные вынесены в файл [values.yaml](./project/values.yaml).

### Задание 2

> Запустить 2 версии в разных неймспейсах.
>
> Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:
> * одну версию в namespace=app1;
> * вторую версию в том же неймспейсе;
> * третью версию в namespace=app2. 

Перед выполнением команд `helm`, необходимо создать новый неймспейс `app1` в кластере. Для этого нужно выполнить следующую команду:

```shell
kubectl create namespace app1
```

И убедиться, что новые неймспесы есть в списке:

```shell
kubectl get ns
```

```text
NAME              STATUS   AGE
app1              Active   66s
default           Active   35m
kube-node-lease   Active   35m
kube-public       Active   35m
kube-system       Active   35m
```

По умолчанию задан `namespace=app1`, таким образом для деплоя chart необходимо выполнить команду:

```shell
helm install netology-project project
```

```text
NAME: netology-project
LAST DEPLOYED: Mon Dec 19 10:36:23 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------

Content of NOTES.txt appears after deploy.
Deployed version 1.0.0.

---------------------------------------------------------
```

Следующим шагом нужно проверить, что chart появился в списке:

```shell
helm list
```

```text
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS CHART            APP VERSION
netology-project        default         1               2022-12-19 10:36:23.9408923 +0700 +07   deployeproject-1.0.0    1.0.0
```

И что все поды запустились:

```shell
kubectl get po --namespace app1
```

```text
NAME                                           READY   STATUS    RESTARTS   AGE
database-0                                     1/1     Running   0          113s
project-production-backend-768887dd4b-vn4ct    1/1     Running   0          113s
project-production-frontend-74d8bb648d-w9wlz   1/1     Running   0          113s
```

Предполагается, что в том же неймспейсе необходимо развернуть данное приложение, но с другим `environment` и с количеством реплик = 2.
Для этого нужно выполнить следующую команду:

```shell
helm install --set "environment=testing" --set "backend.replicasCount=2" netology-project-test project
```

```text
NAME: netology-project-test
LAST DEPLOYED: Mon Dec 19 10:51:48 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------

Content of NOTES.txt appears after deploy.
Deployed version 1.0.0.

---------------------------------------------------------
```

Следующим шагом проверим состояние подов:

```shell
kubectl get po --namespace app1
```

```text
NAME                                           READY   STATUS    RESTARTS   AGE
database-0                                     1/1     Running   0          15m
project-production-backend-768887dd4b-vn4ct    1/1     Running   0          15m
project-production-frontend-74d8bb648d-w9wlz   1/1     Running   0          15m
project-testing-backend-688cb58bdc-74k2m       1/1     Running   0          21s
project-testing-backend-688cb58bdc-r97xv       1/1     Running   0          21s
project-testing-database-0                     1/1     Running   0          21s
project-testing-frontend-7648dfbcb6-th89l      1/1     Running   0          21s
```

Затем необходимо сделать деплой в новый неймспейс. Для этого необходимо выполнить команду:

```shell
helm install --set "namespace=app2" --namespace=app2 --create-namespace netology-project project
```

// todo ошибка
> Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists.
> Unable to continue with install: PersistentVolume "project-production-postgres-pv-volume" in namespace "" exists
> and cannot be imported into the current release: invalid ownership metadata;
> annotation validation error: key "meta.helm.sh/release-name" must equal "netology-project-app2":
> current value is "netology-project";
> annotation validation error: key "meta.helm.sh/release-namespace" must equal "app2":
> current value is "default"
