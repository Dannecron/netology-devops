Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-02-playbook/README.md)
по теме "8.3. Использование Yandex Cloud".

## Q/A

### Задание 1

> Подготовка к выполнению
> 1. Подготовьте в Yandex Cloud три хоста: для [clickhouse](https://clickhouse.com/), для [vector](https://vector.dev) и для [lighthouse](https://github.com/VKCOM/lighthouse)

Предыдущая итерация playbook с установкой `clickhouse` и `vector` перенесена в [playbook](./playbook) из [домашней работы 8.2](/src/homework/08-ansible/8.2).
Дополнительно для `vector` добавлены новые шаги с конфигурированием и запуском как systemd-сервис.

Новая группа хостов добавлена в [inventory/prod.yml.example](./playbook/inventory/prod.yml.example).

### Задание 2

> Основная часть
> 1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
