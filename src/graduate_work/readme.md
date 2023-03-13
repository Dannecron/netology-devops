## Дипломная работа

Выполнение дипломной работы курса netology DevOps инженер. Оригинал задания доступен по [ссылке](https://github.com/netology-code/devops-diplom-yandexcloud/blob/main/README.md).

### Создание облачной инфраструктуры

[Задание](./tasks.md#создание-облачной-инфраструктуры).

#### Предварительная настройка

Предварительная настройка включает в себя несколько шагов, необходимых для последующей работы с `yandex.cloud` через `terraform`.
Данные шаги выполняются в ручную, но могут быть автоматизированы, например, через `ansible`.

1. Установить утилиту [yc](https://cloud.yandex.ru/docs/cli/quickstart) и подключится к облаку.
2. Создание сервисного аккаунта с ролью `editor` на дефолтной директории облака:

    ```shell
    yc iam service-account create --name terraform-acc
    yc resource-manager folder add-access-binding --name default --role editor --subject "serviceAccount:$accId"
    ```
    
    где `$accId` - это уникальный идентификатор нового сервисного аккаунта.
3. Создание s3-bucket для хранения состояния `terraform`

// todo

---

### Создание Kubernetes кластера

[Задание](./tasks.md#создание-Kubernetes-кластера).

/// todo

---

### Создание тестового приложения

[Задание](./tasks.md#создание-тестового-приложения).

[Репозиторий тестового приложения](https://github.com/Dannecron/parcel-example-neko)

/// todo

---

### Подготовка cистемы мониторинга и деплой приложения

[Задание](./tasks.md#подготовка-cистемы-мониторинга-и-деплой-приложения).

/// todo

---

### Установка и настройка CI/CD

[Задание](./tasks.md#установка-и-настройка-CI/CD).

/// todo

---
