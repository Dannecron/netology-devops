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

> В этом задании вы научитесь:
> - создавать и удалять индексы
> - изучать состояние кластера
> - обосновывать причину деградации доступности данных
> 
> Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
> и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:
 
| Имя   | Количество реплик | Количество шард |
|-------|-------------------|-----------------|
| ind-1 | 0                 | 1               |
| ind-2 | 1                 | 2               |
| ind-3 | 2                 | 4               |
 
> Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
> 
> Получите состояние кластера `elasticsearch`, используя API.
> 
> Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
> 
> Удалите все индексы.
> 
> **Важно**
> 
> При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
> иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

Запросы на создание индексов:

```shell
curl --request PUT -sL \
     --url 'http://localhost:9200/ind-1?pretty' \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d '
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}
'

{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}

curl --request PUT -sL \
     --url 'http://localhost:9200/ind-2?pretty' \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d '
{
  "settings": {
    "index": {
      "number_of_shards": 2,  
      "number_of_replicas": 1 
    }
  }
}
'

{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}

curl --request PUT -sL \
     --url 'http://localhost:9200/ind-3?pretty' \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d '
{
  "settings": {
    "index": {
      "number_of_shards": 4,  
      "number_of_replicas": 2
    }
  }
}
'

{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```

Получение списка индексов и их статусы:

```shell
curl --request GET -sL \
     --url 'http://localhost:9200/_cat/indices' \
     -H "Content-Type: application/json"

green  open .geoip_databases 822HE2KlRMuttGzNxhQ6Sw 1 0 40 0 38.1mb 38.1mb
green  open ind-1            Qc4IYuppSm6lolKX5Gu2fA 1 0  0 0   226b   226b
yellow open ind-3            KfDmAYmxSvOmsuPlw8ahqA 4 2  0 0   904b   904b
yellow open ind-2            6Fbu2wMZSu-60LZlSNOvAA 2 1  0 0   452b   452b
```

Здесь часть индексов имеет статус `yellow`, так как в кластере находится только один сервер `elasticsearch`,
а значит индексы не могут реплецироваться согласно их конфигурации по количеству реплик.

Удаление индексов:

```shell
curl --request DELETE -sL \
     --url 'http://localhost:9200/ind-1' \
     -H "Content-Type: application/json"
     
{"acknowledged":true}

curl --request DELETE -sL \
     --url 'http://localhost:9200/ind-2' \
     -H "Content-Type: application/json"

{"acknowledged":true}

curl --request DELETE -sL \
     --url 'http://localhost:9200/ind-3' \
     -H "Content-Type: application/json"

{"acknowledged":true}
```

### Задача 3

> В данном задании вы научитесь:
> - создавать бэкапы данных
> - восстанавливать индексы из бэкапов
> 
> Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.
> 
> Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
> данную директорию как `snapshot repository` c именем `netology_backup`.
> 
> **Приведите в ответе** запрос API и результат вызова API для создания репозитория.
> 
> Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
> 
> [Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
> состояния кластера `elasticsearch`.
> 
> **Приведите в ответе** список файлов в директории со `snapshot`ами.
> 
> Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
> 
> [Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
> кластера `elasticsearch` из `snapshot`, созданного ранее. 
> 
> **Приведите в ответе** запрос к API восстановления и итоговый список индексов.
> 
> Подсказки:
> - возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

Для начала необходимо обновить образ, добавив в [Dockerfile](./elasticsearch/Dockerfile) создание новой директории
по пути `/usr/share/elasticsearch/snapshot`. Далее необходимо добавить новый ключ конфигурации `path.repo` в [elasticsearch.yml](elasticsearch/elasticsearch.yml).

Регистрация новой директории как директории `snapshot`:

```shell
curl --request PUT -sL \
     --url 'http://localhost:9200/_snapshot/netology_backup' \
     -H "Content-Type: application/json" \
     -d '
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/snapshot"
  }
}
'

{"acknowledged":true}

curl --request GET -sL \
     --url 'http://localhost:9200/_snapshot/netology_backup/' \
     -H "Content-Type: application/json"

{"netology_backup":{"type":"fs","settings":{"location":"/usr/share/elasticsearch/snapshot"}}}
```

Создание нового индекса:

```shell
curl --request PUT -sL \
     --url 'http://localhost:9200/test' \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d '
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}
'

{"acknowledged":true,"shards_acknowledged":true,"index":"test"}

curl --request GET -sL \
     --url 'http://localhost:9200/_cat/indices' \
     -H "Content-Type: application/json"

green open .geoip_databases GgHLCD9tQBeeOGnnkPrAqQ 1 0 40 0 38.2mb 38.2mb
green open test             p0tErJUqSXWumKWf2o_Rwg 1 0  0 0   226b   226b
```

Создание `snapshot` состояния `elasticsearch`:

```shell
curl --request PUT -sL \
     --url 'http://localhost:9200/_snapshot/netology_backup/%3Cmy_snapshot_%7Bnow%2Fd%7D%3E?wait_for_completion=true&pretty=true' \
     -H "Content-Type: application/json" \
     -d '
{
  "indices": ["test"],
  "ignore_unavailable": true,
  "include_global_state": false
}
'

{
  "snapshot" : {
    "snapshot" : "my_snapshot_2022.06.08",
    "uuid" : "hXFHeJrnShi4b1JSJUeJCg",
    "repository" : "netology_backup",
    "version_id" : 7160399,
    "version" : "7.16.3",
    "indices" : [
      "test"
    ],
    "data_streams" : [ ],
    "include_global_state" : false,
    "state" : "SUCCESS",
    "start_time" : "2022-06-08T10:50:53.699Z",
    "start_time_in_millis" : 1654685453699,
    "end_time" : "2022-06-08T10:50:53.699Z",
    "end_time_in_millis" : 1654685453699,
    "duration_in_millis" : 0,
    "failures" : [ ],
    "shards" : {
      "total" : 1,
      "failed" : 0,
      "successful" : 1
    },
    "feature_states" : [ ]
  }
}

```

Удаление индекса `test` и создание нового индекса `test-2`:

```shell
curl --request DELETE -sL \
     --url 'http://localhost:9200/test' \
     -H "Content-Type: application/json"

{"acknowledged":true}

curl --request PUT -sL \
     --url 'http://localhost:9200/test-2' \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d '
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}
'

{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}

curl --request GET -sL \
     --url 'http://localhost:9200/_cat/indices' \
     -H "Content-Type: application/json"

green open test-2           YFdNJTp4SraTsWGFSh6YjQ 1 0  0 0   226b   226b
green open .geoip_databases GgHLCD9tQBeeOGnnkPrAqQ 1 0 40 0 38.2mb 38.2mb
```

Получение доступных `snapshot` и восстановление из созданного на предыдущем шаге снимка:

```shell
curl --request GET -sL \
     --url 'http://localhost:9200/_snapshot/netology_backup/*?verbose=false&pretty=true' \
     -H "Content-Type: application/json"
{
  "snapshots" : [
    {
      "snapshot" : "my_snapshot_2022.06.08",
      "uuid" : "hXFHeJrnShi4b1JSJUeJCg",
      "repository" : "netology_backup",
      "indices" : [
        "test"
      ],
      "data_streams" : [ ],
      "state" : "SUCCESS"
    }
  ],
  "total" : 1,
  "remaining" : 0
}


curl --request POST -sL \
     --url 'http://localhost:9200/_snapshot/netology_backup/my_snapshot_2022.06.08/_restore' \
     -H "Content-Type: application/json"
     
{"accepted" : true

curl --request GET -sL \
     --url 'http://localhost:9200/_cat/indices' \
     -H "Content-Type: application/json"

green open .geoip_databases fTbLF8FxREWjni5I7d6SxQ 1 0 40 0 38.2mb 38.2mb
green open test-2           VnS7hBAiTr2-Q6gaaK4gNw 1 0  0 0   226b   226b
green open test             1ZIrIxzTTxCdrUAagtrZMA 1 0  0 0   226b   226b
```
