# Clickhouse and vector playbook

Данный playbook устанавливает `clickhouse`, `vector` и `lighthouse` (доступ через webserver `nginx`) на хосты,
перечисленные в inventory.
Для каждой утилиты может быть указан свой хост для установки. 

## Parameters

### Clickhouse

- `clickhouse_version` - версия `clickhouse`, которая будет установлена
- `clickhouse_packages` - конкретные приложения из стека `clickhouse`, которые будут установлены

### Vector

- `vector_version` - версия `vector`, которая будет установлена

### Lighthouse

// todo

## Tags

### Clickhouse

- `clickhouse` - установка и запуск только `clickhouse`

### Vector

- `vector` - установка только `vector`
- `vector_check_version` - запуск только `task` для проверки текущей установленной версии `vector`

### Lighthouse

// todo
