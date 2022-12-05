Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/13-kubernetes-config-01-objects.md)
по теме "13.1. контейнеры, поды, deployment, statefulset, services, endpoints"

## Q/A

> Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных.

### Задание 1

> Подготовить тестовый конфиг для запуска приложения.
> 
> Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
> * pod содержит в себе 2 контейнера — фронтенд, бекенд;
> * регулируется с помощью deployment фронтенд и бекенд;
> * база данных — через statefulset.

Директория с проектом приложения: [project](/src/homework/13-kubernates-config/project).

В первую очередь необходимо собрать образы приложения и опубликовать их в `registry`,
который будет доступен из кластера. Например, [hub.docker.com](https://hub.docker.com/).

Для этой цели создан репозиторий [dannecron/netology-devops-k8s-app](https://hub.docker.com/repository/docker/dannecron/netology-devops-k8s-app)
и собраны два тега: `frontend-latest` и `backend-latest`.

Итоговая конфигурация для деплоя приложения в кластер k8s будет выглядеть следующим образом: [testing/deployment.yml](./config/testing/deployment.yml).
Здесь будет создано несколько сущностей, а именно:
* `ConfigMap` для хранения конфигурации `postgresql`
* `PersistentVolume` - персистентное дисковое хранилище для базы данных
* `PersistentVolumeClaim` - конфигурация для использования хранилища подами
* `StatefulSet` - разворачивание базы данных `postgresql`
* `Deployment` - разворачивание непосредственно приложения

Применение конфигурации:

```shell
kubectl apply -f testing/deployment.yml 
```

После применения:
```shell
kubectl get pods
```

```text
kubectl get pods
NAME                           READY   STATUS    RESTARTS        AGE
testing-app-57d756f489-r6gw8   2/2     Running   0               4m13s
testing-db-0                   1/1     Running   5 (6m20s ago)   7m53s
```

### Задание 2

> Подготовить конфиг для production окружения.
> 
> Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
> * каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
> * для связи используются service (у каждого компонента свой);
> * в окружении фронта прописан адрес сервиса бекенда;
> * в окружении бекенда прописан адрес сервиса базы данных.

Разделение на отдельные деплойменты будет выглядеть следующим образом:
* БД ([production/database.yml](./config/production/database.yml)) остаётся почти без изменений:
  всё так же будут создаваться `ConfigMap`, `PersistentVolume`, `PersistentVolumeClaim` и сам `StatefulSet`
* Для frontend ([production/frontend.yml](./config/production/frontend.yml)) и backend ([production/backend.yml](./config/production/backend.yml))
  созданы собственные `deployment` и `service`.

Как и в прошлом задании нужно применить данные конфигурации:

```shell
kubectl apply -f production/database.yml
kubectl apply -f production/backend.yml
kubectl apply -f production/frontend.yml
```

Затем нужно проверить, что все поды успешно запустились:

```shell
kubectl get pods
```

```text
NAME                                READY   STATUS    RESTARTS   AGE
prod-app-backend-784f995b5f-vvcr7   1/1     Running   0          84s
prod-app-frontend-947f64949-6vtn7   1/1     Running   0          30s
testing-db-0                        1/1     Running   0          4m15s
```
