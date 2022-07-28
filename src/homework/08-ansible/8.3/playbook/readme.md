# Clickhouse and vector playbook

Данный playbook устанавливает `clickhouse`, `vector` и `lighthouse` (доступ через webserver `nginx`) на хосты,
перечисленные в inventory.
Для каждой утилиты может быть указан свой хост для установки. 

## Parameters

Общие параметры:
- `ansible_user_id` - uid на стороне виртуальной машины
- `ansible_user_gid` - gid на стороне виртуальной машины

### Clickhouse

- `clickhouse_version` - версия `clickhouse`, которая будет установлена
- `clickhouse_packages` - конкретные приложения из стека `clickhouse`, которые будут установлены

### Vector

- `vector_version` - версия `vector`, которая будет установлена

### Lighthouse

- `nginx_username` - имя пользователя, из-под которого будет запущен процесс `nginx`
- `lighthouse_vcs` - путь до репозитория `lighthouse`
- `lighthouse_vcs_version` - версия внутри репозитория `lighthouse` (хэш коммита)
- `lighthouse_location` - путь до директории с `lighthouse`
- `lighthouse_access_log_name` - название лог-файла `nginx` для web-сервиса `lighthouse`

## Tags

### Clickhouse

- `clickhouse` - установка и запуск только `clickhouse`

### Vector

- `vector` - установка только `vector`
- `vector_check_version` - запуск только `task` для проверки текущей установленной версии `vector`

### Lighthouse

- `lighthouse` - установка только `lighthouse`
