Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/master/06-db-04-postgresql/README.md) 
по теме "6.4. PostgreSQL".

## Q/A

### Задача 1

> Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
> 
> Подключитесь к БД PostgreSQL используя `psql`.
> 
> Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.
> 
> **Найдите и приведите** управляющие команды для:
> - вывода списка БД
> - подключения к БД
> - вывода списка таблиц
> - вывода описания содержимого таблиц
> - выхода из psql

Запуск postgresql в docker-контейнере производится с использованием конфигурации [docker-compose.yml](./docker-compose.yml).

Для подключения к БД с использованием `psql` нужно выполнить следующую команду:

```shell
docker-compose exec postgres psql --username=admin --dbname=test_db
```

Команды работы с БД:

```shell
# вывод списка БД
\l
                             List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    | Access privileges 
-----------+-------+----------+------------+------------+-------------------
 postgres  | admin | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin         +
           |       |          |            |            | admin=CTc/admin
 template1 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin         +
           |       |          |            |            | admin=CTc/admin
 test_db   | admin | UTF8     | en_US.utf8 | en_US.utf8 | 

# подключение к БД
\c postgres
You are now connected to database "postgres" as user "admin".

# вывод списка таблиц
\dt
        List of relations
 Schema |  Name   | Type  | Owner 
--------+---------+-------+-------
 public | clients | table | admin
 public | orders  | table | admin

# вывод описания содержимого таблиц
\d orders
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

# выход из psql
\q
```

### Задача 2

> Используя `psql` создайте БД `test_database`.
> 
> Изучите [бэкап БД](./dump/test_dump.sql).
> 
> Восстановите бэкап БД в `test_database`.
> 
> Перейдите в управляющую консоль `psql` внутри контейнера.
> 
> Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
> 
> Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/13/view-pg-stats), найдите столбец таблицы `orders` 
> с наибольшим средним значением размера элементов в байтах.
> 
> **Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

Для восстановления дампа нужно выполнить следующую последовательность команд:

```shell
docker-compose exec postgres sh
cd /opt/dump/
psql -Uadmin -dtest_database < test_dump.sql
psql -Uadmin -dtest_database
\dt
        List of relations
 Schema |  Name  | Type  | Owner 
--------+--------+-------+-------
 public | orders | table | admin
(1 row)
```

Для сбора статистики по таблице, нужно выполнить следующий запрос:

```sql
analyze verbose orders;
-- INFO:  analyzing "public.orders"
-- INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
-- ANALYZE
```

Вывод информации по таблице:

```sql
select tablename, attname, avg_width from pg_stats where tablename like 'orders';
--  tablename | attname | avg_width 
-- -----------+---------+-----------
--  orders    | id      |         4
--  orders    | title   |        16
--  orders    | price   |         4
-- (3 rows)
```

Таким образом, наибольшее среднее значение размера элементов у столбца `title` с размером 16 байт.

### Задача 3

> Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
> поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
> провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
> 
> Предложите SQL-транзакцию для проведения данной операции.
> 
> Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Для партицирования существующей таблицы (шардирование таблицы в рамках текущего инстанса БД)
необходимо использовать функционал наследования и создать две таблицы, которые наследуют базовую. 

```sql
create table orders_1 (
    constraint pk_orders_1 primary key (id),
    constraint ck_orders_1 check ( price > 499)
) inherits (orders);

create table orders_2 (
    constraint pk_orders_2 primary key (id),
    constraint ck_orders_2 check ( price <= 499)
) inherits (orders);
```

При этом, запись в основную таблицу не переведёт данные в дочерние таблицы. Для этого необходимо написать триггер,
который будет все новые данные записывать в дочерние таблицы:

```sql
CREATE OR REPLACE FUNCTION insert_new_order()
RETURNS TRIGGER AS $$
begin
	if (NEW.price > 499) then
		insert into orders_1 values (NEW.*);
	else
		insert into orders_2 values (NEW.*);
	end if;

	return null;
end;
$$
LANGUAGE plpgsql;

create trigger insert_new_orders_trigger
    before insert on orders
    for each row execute function insert_new_order();
```

Теперь новые данные, которые будут записываться в таблицу `orders` будут физически попадать в одну из таблиц `orders_1` или `orders_2`,
но при этом при запросе к родительской таблице эти данные будут видны.

На этапе проектирования структуры БД необходимо выделять таблицы, которые будут иметь очень большой размер.
В этом случае можно использовать нативный функционал партицирования, который может быть активирован только при создании таблицы.

Таким образом, создание таблицы `orders` в самом начале создания схемы выглядело бы следующим образом:

```sql
CREATE TABLE orders (
	id serial4 NOT NULL,
	title varchar(80) NOT NULL,
	price int4 NULL DEFAULT 0,
	CONSTRAINT orders_pkey PRIMARY KEY (id)
) PARTITION BY RANGE (price);

CREATE TABLE orders_1 PARTITION OF orders
    FOR VALUES FROM (500) TO (maxvalue);
    
CREATE TABLE orders_2 PARTITION OF orders
    FOR VALUES FROM (minvalue) to (500);
```

### Задача 4

> Используя утилиту `pg_dump` создайте бекап БД `test_database`.
> 
> Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Создание бэкапа базы данных:

```shell
docker-compose exec postgres sh
pg_dump -Uadmin -dtest_database > /opt/dump/test_database.sql
```

Есть два варианта, как можно сделать `title` уникальным:

1. Предпочтительный способ. Необходимо выполнить запрос `alter table orders add constraint orders_tilte_unique unique (title);` 
  на текущей работающей БД, а затем снять дамп.
2. Так как дамп БД - это набор sql-скриптов, то можно добавить запрос непосредственно в файл `test_database.sql`.
  Но в данном случае изменения применяться только для БД, на которых будет применён этот дамп.
