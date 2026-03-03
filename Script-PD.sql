
-- sebastian_mejia_pd.mega_store_raw definition

-- Drop table

-- DROP TABLE sebastian_mejia_pd.mega_store_raw;

CREATE TABLE sebastian_mejia_pd.mega_store_raw (
	transaction_id varchar(50) NULL,
	"date" varchar(50) NULL
	customer_name varchar(50) NULL
	customer_email varchar(50) NULL
	customer_address varchar(50) NULL
	customer_phone int8 NULL
	product_category varchar(50) NULL,
	product_name varchar(50) NULL,
	product_sku varchar(50) NULL,
	unit_price int4 NULL,
	quantity int4 NULL,
	total_line_value int4 NULL
	supplier_name varchar(50) NULL
	supplier_email varchar(50) null	
);

create table customers (
	customer_id serial primary key,
	name varchar(150) not null,
	email varchar(150) not null,
	address text not null,
	phone varchar(20) not null
		
);

create table categorys (
	category_id serial primary key,
	name varchar(150) not null
);

create table suppliers (
	supplier_id serial primary key,
	name varchar(150) not null,
	email varchar(150) not null
);

create table products (
	product_id serial primary key,
	category_id serial not null,
	name varchar(150) not null,
	sku varchar(20) not null,
	
	constraint fk_product_category
		foreign key (category_id)
		references categorys (category_id)
		on delete cascade
		on update cascade
);

create table transactions (
	transaction_id uuid primary key,
	customer_id serial not null,
	transaction_id_former varchar(20), 
	trasnsaction_date date not null,
	total numeric(20,2) not null,
	
	constraint fk_transaction_customer
		foreign key (customer_id)
		references customers (customer_id)
		on delete cascade
		on update cascade
);

create table transaction_items (
	transaction_items_id uuid primary key,
	transaction_id uuid not null,
	product_id serial not null,
	supplier_id serial not null,
	quantity integer not null,
	unit_price numeric(10,2) not null,
	
	constraint fk_transactionitems_transaction
		foreign key (transaction_id)
		references transactions (transaction_id)
		on delete cascade
		on update cascade,
		
	constraint fk_transactionitems_product
		foreign key (product_id)
		references products (product_id)
		on delete cascade
		on update cascade,
		
	constraint fk_transactionitems_supplier
		foreign key (supplier_id)
		references suppliers (supplier_id)
		on delete cascade
		on update cascade
);

insert into customers (name, email, address, phone)
select distinct 
	customer_name, 
	customer_email, 
	customer_address, 
	customer_phone
from mega_store_raw

insert into categorys (name)
select distinct product_category
from mega_store_raw

insert into suppliers (name, email)
select distinct supplier_name, supplier_email
from mega_store_raw

insert into products (category_id, name, sku)
select distinct 
	c.name,
	msr.product_name,
	msr.product_sku 
from mega_store_raw msr 
join categorys c on msr.product_name = c."name";

insert into transactions (
transaction_id,
customer_id,
transaction_id_former,
trasnsaction_date,
total
)
select distinct 
	gen_random_uuid(),
	c.customer_id,
	msr.transaction_id,
	msr.date::date,
	sum(msr.total_line_value) over (partition by msr.transaction_id)
from mega_store_raw msr
join customers c on msr.customer_email = c.email;

insert into transaction_items (
transaction_items_id,
transaction_id,
product_id,
supplier_id,
quantity,
unit_price
)
select
	gen_random_uuid(),
	t.transaction_id,
	s.supplier_id,
	msr.quantity,
	msr.unit_price::numeric(10,2)
from mega_store_raw msr
join transactions t on msr.transaction_id = t.transaction_id_former
join products p on msr.product_sku
join suppliers s on msr.supplier_email = s.email;
