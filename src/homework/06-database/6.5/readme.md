Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/master/06-db-05-elasticsearch/README.md) 
по теме "6.5. Elasticsearch".

## Q/A

### Задача 1

> В этом задании вы потренируетесь в:
> - установке elasticsearch
> - первоначальном конфигурировании elastcisearch
> - запуске elasticsearch в docker
> 
> Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:
> 
> - составьте Dockerfile-манифест для elasticsearch
> - соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
> - запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины
> 
> Требования к `elasticsearch.yml`:
> - данные `path` должны сохраняться в `/var/lib` 
> - имя ноды должно быть `netology_test`
> 
> В ответе приведите:
> - текст Dockerfile манифеста
> - ссылку на образ в репозитории dockerhub
> - ответ `elasticsearch` на запрос пути `/` в json виде
> 
> Подсказки:
> - при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
> - при некоторых проблемах вам поможет docker директива ulimit
> - elasticsearch в логах обычно описывает проблему и пути ее решения
> - обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
> - если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
> - при настройке `path` возможно потребуется настройка прав доступа на директорию

Сборка происходит по описанию из [elasticsearch/Dockerfile](./elasticsearch/Dockerfile).
Основная конфигурация `elasticsearch` представлена в [elasticsearch/elasticsearch.yml(./elasticsearch/elasticsearch.yml).

Образ собран и расположен [в репозитории на hub.docker.com](https://hub.docker.com/r/dannecron/netology-devops-elasticsearch).

Для запуска уже собранного образа используется конфигурация [docker-compose.yml](./docker-compose.yml).
Здесь на хост "проброшен" порт `9200`, поэтому можно выполнить следующий запрос для получение информации от `elasticsearch`:

```shell
curl --request GET -sL \
     --url 'http://localhost:9200/' \
     -H "Content-Type: application/json" \
     -H "Accept: application/json"

{
  "name" : "netology_test",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "RiOGXZdfR6-0v22HKRWRuA",
  "version" : {
    "number" : "7.16.3",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "4e6e4eab2297e949ec994e688dad46290d018022",
    "build_date" : "2022-01-06T23:43:02.825887787Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

### Задача 2

// todo

### Задача 3

// todo