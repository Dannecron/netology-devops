create table orders
(
    id serial primary key,
    name varchar(255),
    price integer
);

create table clients
(
    id serial primary key,
    last_name varchar(255),
    country varchar(255),
    order_id integer constraint client_order_fk references orders (id) on delete cascade on update no action
);
