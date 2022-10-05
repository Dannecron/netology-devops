Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/10-monitoring-03-grafana/README.md)
по теме "10.3. Системы Grafana"

## Q/A

### Задание 1

> Cамостоятельно разверните grafana, где в роли источника данных будет выступать prometheus, а сборщиком данных node-exporter:
> 
> * `grafana`
> * `prometheus-server`
> * `prometheus node-exporter`
> 
> Запустите связку prometheus-grafana.
> Зайдите в веб-интерфейс Grafana, используя авторизационные данные, указанные в манифесте docker-compose.
> Подключите поднятый вами prometheus как источник данных.
> Решение домашнего задания - скриншот веб-интерфейса grafana со списком подключенных Datasource.
> В решении к домашнему заданию приведите также все конфигурации/скрипты/манифесты, которые вы использовали в процессе решения задания.

`docker-compose` и остальная конфигурация расположена в директории [stack](./stack).
При поднятии контейнеров в `grafana` автоматически создаётся `data-source` к `prometheus`,
а так же dashboard по мониторингу контейнера `prometheus`.

![grafana_datasource](./img/grafana_datasource.png)

### Задание 2

> Изучите самостоятельно ресурсы:
> - [promql-for-humans](https://timber.io/blog/promql-for-humans/#cpu-usage-by-instance)
> - [understanding prometheus cpu metrics](https://www.robustperception.io/understanding-machine-cpu-usage)
> 
> Создайте Dashboard и в ней создайте следующие Panels:
> - Утилизация CPU для nodeexporter (в процентах, 100-idle)
> - CPULA 1/5/15
> - Количество свободной оперативной памяти
> - Количество места на файловой системе
> 
> Для решения данного ДЗ приведите promql запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

Метрики и текст запросов для них

- Утилизация CPU для nodeexporter (в процентах, 100-idle)

```text
100 * (1 - avg by(instance)(irate(node_cpu_seconds_total{mode="idle"}[1m])))
```

- CPULA 1/5/15

```text
avg(node_load1{})
avg(node_load5{})
avg(node_load15{})
```

- Количество свободной оперативной памяти

// todo

- Количество места на файловой системе

// todo
