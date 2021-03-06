Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/master/06-db-02-sql/README.md) 
по теме "6.2. SQL".

## Q/A

### Задача 1

> Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.
> 
> Приведите получившуюся команду или docker-compose манифест.

Описание сервиса postgresql в файле [docker-compose.yml](./docker-compose.yml).

### Задача 2

> В БД из [задачи 1](#задача-1): 
> - создайте пользователя test-admin-user и БД test_db
> - в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
> - предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
> - создайте пользователя test-simple-user  
> - предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
> 
> Таблица orders:
> - id (serial primary key)
> - наименование (string)
> - цена (integer)
> 
> Таблица clients:
> - id (serial primary key)
> - фамилия (string)
> - страна проживания (string, index)
> - заказ (foreign key orders)
> 
> Приведите:
> - итоговый список БД после выполнения пунктов выше,
> - описание таблиц (describe)
> - SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
> - список пользователей с правами над таблицами test_db

В рамках выполнения [задачи 1](#задача-1) через переменные окружения (`POSTGRES_DB: test_db`) было проставлено название базы данных,
которую необходимо создать при первом запуске контейнера. Таким образом, вручную создавать данную БД не нужно.

Но если необходимо создать ещё одну базу данных, то это можно сделать следующими командами:
```shell
docker-compose exec postgres sh
createdb --username=admin some_db
```

Далее создадим пользователей. Для начала подключимся к БД с помощью утилиты `psql`:
```shell
docker-compose exec postgres psql --username=admin --dbname=test_db
```

Затем выполним следующие sql-команды:
```sql
CREATE USER "test-admin-user" WITH PASSWORD '123';
CREATE USER "test-simple-user" WITH PASSWORD '123';
```

После этого, создадим таблицы. Скрипты для создания таблиц в БД: [migration_structure.sql](./migration_structure.sql).

Следующим шагом, дадим права новым пользователям:

```sql
GRANT ALL PRIVILEGES ON DATABASE "test_db" to "test-admin-user";
REVOKE ALL PRIVELEGES ON ON DATABASE "test_db" from "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "public" to "test-simple-user";
```

* итоговый список БД после выполнения пунктов выше

```shell
test_db-# \l
                                  List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    |      Access privileges      
-----------+-------+----------+------------+------------+-----------------------------
 postgres  | admin | UTF8     | en_US.utf8 | en_US.utf8 | 
 some_db   | admin | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin                   +
           |       |          |            |            | admin=CTc/admin
 template1 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin                   +
           |       |          |            |            | admin=CTc/admin
 test_db   | admin | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/admin                  +
           |       |          |            |            | admin=CTc/admin            +
           |       |          |            |            | "test-admin-user"=CTc/admin
```

* описание таблиц (describe)

```shell
test_db=# \dt
        List of relations
 Schema |  Name   | Type  | Owner 
--------+---------+-------+-------
 public | clients | table | admin
 public | orders  | table | admin

test_db=# \d orders
                                    Table "public.orders"
 Column |          Type          | Collation | Nullable |              Default               
--------+------------------------+-----------+----------+------------------------------------
 id     | integer                |           | not null | nextval('orders_id_seq'::regclass)
 name   | character varying(255) |           |          | 
 price  | integer                |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "client_order_fk" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE

test_db=# \d clients
                                     Table "public.clients"
  Column   |          Type          | Collation | Nullable |               Default               
-----------+------------------------+-----------+----------+-------------------------------------
 id        | integer                |           | not null | nextval('clients_id_seq'::regclass)
 last_name | character varying(255) |           |          | 
 country   | character varying(255) |           |          | 
 order_id  | integer                |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "client_order_fk" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
```

* SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```sql
SELECT 
    table_schema, table_catalog, table_name, grantee, privilege_type
FROM information_schema.table_privileges
WHERE table_catalog like 'test_db';
```

* список пользователей с правами над таблицами test_db

```shell
"PUBLIC"
"admin"
"test-simple-user"
```

### Задача 3

> Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:
> 
> Таблица orders

| Наименование | цена |
|--------------|------|
| Шоколад      | 10   |
| Принтер      | 3000 |
| Книга        | 500  |
| Монитор      | 7000 |
| Гитара       | 4000 |
 
> Таблица clients

| ФИО                  | Страна проживания |
|----------------------|-------------------|
| Иванов Иван Иванович | USA               |
| Петров Петр Петрович | Canada            |
| Иоганн Себастьян Бах | Japan             |
| Ронни Джеймс Дио     | Russia            |
| Ritchie Blackmore    | Russia            |

> Используя SQL синтаксис:
> - вычислите количество записей для каждой таблицы 
> - приведите в ответе:
>     - запросы 
>     - результаты их выполнения.

Скрипты заполнения таблиц данными: [migration_data.sql](./migration_data.sql).

Запросы на получение количество записей в таблицах:

```sql
-- для таблицы orders
select count(id) from orders;
-- Результат: 5

-- для таблицы clients
select count(id) from clients;
-- Результат: 5
```

### Задача 4

> Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
> 
> Используя foreign keys свяжите записи из таблиц, согласно таблице:
> 
| ФИО                  | Заказ   |
|----------------------|---------|
| Иванов Иван Иванович | Книга   |
| Петров Петр Петрович | Монитор |
| Иоганн Себастьян Бах | Гитара  |
> 
> Приведите SQL-запросы для выполнения данных операций.
> 
> Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
>  
> Подсказка - используйте директиву `UPDATE`.

Запросы на проставление связи между клиентами и заказами:

```sql
update clients 
set order_id = (
    select id
    from orders
    where orders.name like 'Книга'
) 
where clients.last_name like 'Иванов Иван Иванович';

update clients 
set order_id = (
    select id
    from orders
    where orders.name like 'Монитор'
) 
where clients.last_name like 'Иванов Иван Иванович';

update clients 
set order_id = (
    select id
    from orders
    where orders.name like 'Гитара'
) 
where clients.last_name like 'Иоганн Себастьян Бах';
```

Запрос на вывод всех пользователей, которые совершили заказ:

```sql
select * from clients where order_id is not null;
```

Результат данного запроса:

| id  | last_name            | country | order_id |
|-----|----------------------|---------|----------|
| 1   | Иванов Иван Иванович | USA     | 3        |
| 2   | Петров Петр Петрович | Canada  | 4        |
| 3   | Иоганн Себастьян Бах | Japan   | 5        |


### Задача 5

> Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
> (используя директиву EXPLAIN).
> 
> Приведите получившийся результат и объясните что значат полученные значения.

Запрос на получение анализа запроса из [задачи 4](#задача-4):

```sql
explain select * from clients where order_id is not null;
```

Результат выполнения:

```text
"QUERY PLAN"
"Seq Scan on clients  (cost=0.00..10.70 rows=70 width=1040)"
"  Filter: (order_id IS NOT NULL)"
```

Данный результат можно проанализировать следующим образом:
* `Seq Scan on clients` - последовательное сканирование всех записей в таблице (простой перебор записей).
* `cost=0.00` - приблизительная стоимость запуска запроса. Это время, которое проходит, прежде чем начнётся этап вывода данных.
* `..10.70` - приблизительная общая стоимость запроса. Определяется наихудший вариант выполнения,
  когда необходимо проанализировать и вывести все строки в таблице.
* `rows=70` - ожидаемое число строк, которое вернёт запрос в наихудшем варианте выполнения.
* `width=1040` - ожидаемый средний размер строк, которые отдаст запрос (в байтах).
* `Filter: (order_id IS NOT NULL)` - применение фильтра на проверку на null. В данном случае 
  фильтр будет применён к каждой записи из таблицы.

Подробнее про [использование EXPLAIN](https://postgrespro.ru/docs/postgrespro/12/using-explain)

### Задача 6

> Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
> 
> Остановите контейнер с PostgreSQL (но не удаляйте volumes).
> 
> Поднимите новый пустой контейнер с PostgreSQL.
> 
> Восстановите БД test_db в новом контейнере.
> 
> Приведите список операций, который вы применяли для бэкапа данных и восстановления.

Создание бэкапа базы данных:

```shell
docker-compose exec postgres sh
pg_dump -Uadmin -dtest_db > test_db.sql
```

Остановка текущего контейнера с БД и запуск нового:

```shell
docker-compose stop postgres
docker run --rm -d --name=netology_dump_postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=123 \
  -v 62_netology_pgdump:/opt/pgdump -w /opt/pgdump \
  postgres:12.11-alpine
```

Применение дампа в новом инстансе БД:

```shell
docker exec -it netology_dump_postgres sh
psql -Uadmin -c"CREATE DATABASE test_db;"
psql -Uadmin -dtest_db < test_db.sql
psql -Uadmin -dtest_db

test_db=# \l
   Name    | Owner | Encoding |  Collate   |   Ctype    | Access privileges 
-----------+-------+----------+------------+------------+-------------------
 admin     | admin | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | admin | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin         +
           |       |          |            |            | admin=CTc/admin
 template1 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin         +
           |       |          |            |            | admin=CTc/admin
 test_db   | admin | UTF8     | en_US.utf8 | en_US.utf8 | 

test_db=# \dt
        List of relations
 Schema |  Name   | Type  | Owner 
--------+---------+-------+-------
 public | clients | table | admin
 public | orders  | table | admin
```