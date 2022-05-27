Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/master/06-db-03-mysql/README.md) 
по теме "6.3. MySQL".

## Q/A

### Задача 1

> Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
> 
> Изучите [бэкап БД](./dump/test_dump.sql) и восстановитесь из него.
> 
> Перейдите в управляющую консоль mysql внутри контейнера.
> 
> Используя команду \h получите список управляющих команд.
> 
> Найдите команду для выдачи статуса БД и приведите в ответе из ее вывода версию сервера БД.
> 
> Подключитесь к восстановленной БД и получите список таблиц из этой БД.
> 
> Приведите в ответе количество записей с price > 300.
> 
> В следующих заданиях мы будем продолжать работу с данным контейнером.

Для запуска контейнера с mysql будет использована конфигурация [docker-compose.yml](./docker-compose.yml).

Для восстановления из бэкапа нужно выполнить следующую команду:

```shell
docker-compose exec mysql bash -c "mysql -uroot -p123 -e 'CREATE DATABASE test_db'"
docker-compose exec mysql bash -c "mysql -uroot -p123 -Dtest_db < /opt/dump/test_dump.sql"
```

Затем нужно подключиться к БД и вывести статус:

```shell
docker-compose exec mysql mysql -uroot -p123
mysql> \status
--------------
mysql  Ver 8.0.15 for Linux on x86_64 (MySQL Community Server - GPL)
<...>
```

Подключение к восстановленной базе данных, вывод списка таблиц
и получение всех записей из таблицы `orders` с условием `price > 300`:

```shell
mysql> \u test_db
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed

mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> select count(id) from orders where orders.price > 300;
+-----------+
| count(id) |
+-----------+
|         1 |
+-----------+
1 row in set (0.00 sec)
```

### Задача 2

> Создайте пользователя `test` в БД c паролем `test-pass`, используя:
> - плагин авторизации mysql_native_password
> - срок истечения пароля - 180 дней
> - количество попыток авторизации - 3
> - максимальное количество запросов в час - 100
> - аттрибуты пользователя:
>     - Фамилия "Pretty"
>     - Имя "James"
>
> Предоставьте привилегии пользователю `test` на операции SELECT базы `test_db`.
> 
> Используя таблицу `INFORMATION_SCHEMA.USER_ATTRIBUTES` получите данные по пользователю `test` и приведите в ответе к задаче.

Запрос на создание пользователя:

```sql
CREATE USER 'test' 
  IDENTIFIED WITH mysql_native_password BY 'test-pass'
  WITH MAX_QUERIES_PER_HOUR 100
  PASSWORD EXPIRE INTERVAL 180 DAY
  FAILED_LOGIN_ATTEMPTS 3
  ATTRIBUTE '{"lname": "Pretty", "fname": "James"}';
```

Запрос на предоставление привилегий новому пользователю:

```sql
GRANT SELECT ON test_db.* TO 'test';
```

Запрос на получение данных о новом пользователе и его результат:

```shell
mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES where USER like 'test';
+------+------+---------------------------------------+
| USER | HOST | ATTRIBUTE                             |
+------+------+---------------------------------------+
| test | %    | {"fname": "James", "lname": "Pretty"} |
+------+------+---------------------------------------+
1 row in set (0.00 sec)
```

### Задача 3

> Установите профилирование `SET profiling = 1`.
> Изучите вывод профилирования команд `SHOW PROFILES;`.
> 
> Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
> 
> Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
> - на `MyISAM`
> - на `InnoDB`

// todo

### Задача 4

> Изучите файл `my.cnf` в директории /etc/mysql.
> 
> Измените его согласно ТЗ (движок InnoDB):
> - Скорость IO важнее сохранности данных
> - Нужна компрессия таблиц для экономии места на диске
> - Размер буффера с незакомиченными транзакциями 1 Мб
> - Буффер кеширования 30% от ОЗУ
> - Размер файла логов операций 100 Мб
> 
> Приведите в ответе измененный файл `my.cnf`.

// todo
