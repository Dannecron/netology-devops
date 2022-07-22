# Clickhouse and vector playbook

Данный playbook устанавливает `clickhouse` и `vector` на хосты, перечисленные в inventory.
Для каждой утилиты может быть указан свой хост для установки. 

## Parameters

### Clickhouse

- `clickhouse_version` - версия `clickhouse`, которая будет установлена
- `clickhouse_packages` - конкретные приложения из стека `clickhouse`, которые будут установлены

### Vector

- `vector_version` - версия `vector`, которая будет установлена

## Tags

### Clickhouse

- `clickhouse` - установка и запуск только `clickhouse`

### Vector

- `vector` - установка только `vector`
- `vector_check_version` - запуск только `task` для проверки текущей установленной версии `vector`
