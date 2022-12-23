Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/13-kubernetes-config-05-qbec.md)
по теме "13.5. поддержка нескольких окружений на примере Qbec"

## Q/A

> Приложение обычно существует в нескольких окружениях. Для удобства работы следует использовать соответствующие инструменты, например, Qbec.

### Задание 1

Подготовить приложение для работы через qbec.

> Приложение следует упаковать в qbec. Окружения должно быть 2: stage и production.

> Требования:
> * stage окружение должно поднимать каждый компонент приложения в одном экземпляре;
> * production окружение — каждый компонент в трёх экземплярах;
> * для production окружения нужно добавить endpoint на внешний адрес.

Для начала необходимо установить две утилиты: `jsonnet` и `qbec`.

Для простоты оригинальная утилита [jsonnet](https://github.com/google/jsonnet) будет заменена на её [официальную реализацию на языке go](https://github.com/google/go-jsonnet).
Установка:

* Скачать последний релиз с `github`

    ```shell
    curl -LO https://github.com/google/go-jsonnet/releases/download/v0.19.1/go-jsonnet_0.19.1_Linux_x86_64.tar.gz
    ```

* Распаковать архив

    ```shell
    tar -zxf go-jsonnet_0.19.1_Linux_x86_64.tar.gz
    ```

* Переместить файлы `jsonnet` и `jsonnetfmt` в директорию с исполняемыми файлами (н-р, `~/.local/bin`)

    ```shell
    mv jsonnet ~/.local/bin && mv jsonnetfmt ~/.local/bin
    ```

* Не забыть удалить оставшиеся файлы

    ```shell
    rm -f LICENSE README.md go-jsonnet_0.19.1_Linux_x86_64.tar.gz
    ```

Для установки `qbec`:

* Скачать последний релиз с `github`

    ```shell
    curl -OL https://github.com/splunk/qbec/releases/download/v0.15.2/qbec-linux-amd64.tar.gz
    ```

* Распаковать архив

    ```shell
    tar -zxf qbec-linux-amd64.tar.gz
    ```

* Переместить файл `qbec` в директорию с исполняемыми файлами (н-р, `~/.local/bin`)

    ```shell
    mv qbec ~/.local/bin
    ```

* Не забыть удалить оставшиеся файлы

    ```shell
    rm -f CHANGELOG.md LICENSE README.md jsonnet-qbec licenselint.sh qbec-linux-amd64.tar.gz
    ```

Конфигурация `qbec` расположена в директории [project](./project). Конфигурация состоит из 4-х компонентов:

* [backend](./project/components/backend.jsonnet): Deployment и Service для backend части приложения
* [frontend](./project/components/frontend.jsonnet): Deployment и Service для frontend части приложения
* [database](./project/components/database.jsonnet): StatefulSet базы данных вместе с некоторыми дополнительными компонентами (ConfigMap, PV, PVC)
* [local_google](./project/components/local_google.jsonnet): Endpoint для одного из ip-адресов `google.com`

Чтобы убедится, что конфигурация в порядке, можно провести валидацию:

```shell
qbec validate stage
qbec validate production
```

Затем нужно приступить к деплою приложения на окружение `stage`:

```shell
qbec apply stage --show-details
```

Затем нужно убедиться, что деплой прошёл успешно:

```shell
kubectl get po
```

```text
NAME                        READY   STATUS    RESTARTS   AGE
backend-5b6584cddb-2sbvw    1/1     Running   0          60s
db-0                        1/1     Running   0          59s
frontend-7b79b7d798-l6khv   1/1     Running   0          60s
```

Аналогично необходимо развернуть приложение на окружение `production`, но перед этим необходимо создать namespace с именем `production`:

```shell
kubectl create namespace production
```

```shell
qbec apply production
```

Проверка, что все поды запущены штатно:

```shell
 kubectl --namespace=production get po
```

```text
NAME                        READY   STATUS    RESTARTS   AGE
backend-5b6584cddb-lpp4p    1/1     Running   0          42s
backend-5b6584cddb-t8nzc    1/1     Running   0          42s
backend-5b6584cddb-w79xl    1/1     Running   0          42s
db-0                        1/1     Running   0          41s
frontend-7b79b7d798-b4ct4   1/1     Running   0          42s
frontend-7b79b7d798-blnft   1/1     Running   0          42s
frontend-7b79b7d798-rbssh   1/1     Running   0          42s
```
