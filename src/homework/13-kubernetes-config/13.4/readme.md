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

И убедиться, что новый неймспейс есть в списке:

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

Для деплоя chart необходимо выполнить команду:

```shell
helm install --namespace=app1 netology-project project
```

```text
NAME: netology-project
LAST DEPLOYED: Tue Dec 20 10:46:14 2022
NAMESPACE: app1
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
helm list --namespace=app1
```

```text
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS CHART            APP VERSION
netology-project        app1            1               2022-12-20 10:46:14.3054387 +0700 +07   deployeproject-1.0.0    1.0.0
```

И что все поды запустились:

```shell
kubectl get po --namespace app1
```

```text
NAME                                           READY   STATUS    RESTARTS   AGE
project-production-backend-768887dd4b-8zb7h    1/1     Running   0          102s
project-production-database-0                  1/1     Running   0          102s
project-production-frontend-74d8bb648d-9tc6g   1/1     Running   0          102s
```

Предполагается, что в том же неймспейсе необходимо развернуть данное приложение, но с другим `environment`
и с количеством реплик backend равным 2.
Для этого нужно выполнить следующую команду:

```shell
helm install --namespace=app1 --set "environment=testing" --set "backend.replicasCount=2" netology-project-test project
```

```text
NAME: netology-project-test
LAST DEPLOYED: Tue Dec 20 10:48:34 2022
NAMESPACE: app1
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
project-production-backend-768887dd4b-8zb7h    1/1     Running   0          2m38s
project-production-database-0                  1/1     Running   0          2m38s
project-production-frontend-74d8bb648d-9tc6g   1/1     Running   0          2m38s
project-testing-backend-688cb58bdc-5fqfd       1/1     Running   0          19s
project-testing-backend-688cb58bdc-hz9jp       1/1     Running   0          19s
project-testing-database-0                     1/1     Running   0          18s
project-testing-frontend-7648dfbcb6-t7mv9      1/1     Running   0          19s
```

Затем необходимо сделать деплой в новый неймспейс. Для этого необходимо выполнить команду:

```shell
helm install --namespace=app2 --create-namespace netology-project-app2 project
```

```text
NAME: netology-project
LAST DEPLOYED: Tue Dec 20 10:53:35 2022
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------

Content of NOTES.txt appears after deploy.
Deployed version 1.0.0.

---------------------------------------------------------
```

Далее нужно проверить, что деплой прошёл и поды запустились:

```shell
helm --namespace=app2 list
```

```text
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS CHART            APP VERSION
netology-project        app2            1               2022-12-20 10:53:35.7784271 +0700 +07   deployeproject-1.0.0    1.0.0
```

```shell
kubectl get po --namespace=app2
```

```text
NAME                                           READY   STATUS    RESTARTS   AGE
project-production-backend-768887dd4b-m8sb7    1/1     Running   0          101s
project-production-database-0                  1/1     Running   0          101s
project-production-frontend-74d8bb648d-wrm49   1/1     Running   0          101s
```


_Note:_ Была проблема с созданием `PV`. По всей видимости вольюм создаётся глобально, вне неймспейсов.
Таким образом, пришлось сделать название объекта `PV` зависимым от неймспейса, в котором запускается деплой `helm`.
