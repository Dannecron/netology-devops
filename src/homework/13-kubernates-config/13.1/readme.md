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

// todo

### Задание 3

> Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
> * добавлен endpoint до внешнего api (например, геокодер).

// todo
