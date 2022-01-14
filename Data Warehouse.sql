CREATE TABLE dimDate
(
	date_key integer NOT NULL PRIMARY KEY,
	date date NOT NULL,
	year smallint NOT NULL,
	quarter smallint NOT NULL,
	month smallint NOT NULL,
	day smallint NOT NULL,
	week smallint NOT NULL,
	is_weekend boolean
);

select column_name,data_type from information_schema.columns where table_name='dimdate'

CREATE TABLE dimCustomer
(
	customer_key SERIAL PRIMARY KEY,
	customer_id smallint NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	email varchar(50),
	address varchar(50) NOT NULL,
	address2 varchar(50),
	district varchar(20) NOT NULL,
	city varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	postal_code varchar(10),
	phone varchar(20) NOT NULL,
	active smallint NOT NULL,
	create_date timestamp NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL
);


CREATE TABLE dimStore
(
	store_key SERIAL PRIMARY KEY,
	store_id smallint NOT NULL,
	address varchar(50) NOT NULL,
	address2 varchar(50),
	district varchar(20) NOT NULL,
	city varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	postal_code varchar(10),
	manager_first_name varchar(45) NOT NULL,
	manager_last_name varchar(45) NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL
);

CREATE TABLE dimFilm
(
	film_key SERIAL PRIMARY KEY,
	film_id smallint NOT NULL,
	title varchar(255) NOT NULL,
	description text,
	release_year year,
	language varchar(20) NOT NULL,
	original_language varchar(20),
	rental_duration smallint NOT NULL,
	length smallint NOT NULL,
	ratings varchar(5) NOT NULL,
	special_features varchar(60) NOT NULL
	
);

INSERT INTO dimDate
(date_key,date,year,quarter,month,day,week,is_weekend)
SELECT
	DISTINCT (TO_CHAR(payment_date :: DATE,'yyMMDD')::integer) as date_key,
	date (payment_date) as date,
	EXTRACT (year from payment_date) as year,
	EXTRACT (quarter from payment_date) as quarter,
	EXTRACT (month from payment_date) as month,
	EXTRACT (day from payment_date) as day,
	EXTRACT (week from payment_date) as week,
	CASE WHEN EXTRACT (ISODOW FROM payment_date) IN (6,7) THEN true ELSE false END AS is_weekend
FROM payment;

select * from dimDate;
select payment_date from  payment limit 10;


INSERT INTO dimDate
(date_key,date,year,quarter,month,day,week,is_weekend)
SELECT
	DISTINCT (TO_CHAR(payment_date :: DATE,'yyMMDD')::integer) as date_key,
	date (payment_date) as date,
	EXTRACT (year from payment_date) as year,
	EXTRACT (quarter from payment_date) as quarter,
	EXTRACT (month from payment_date) as month,
	EXTRACT (day from payment_date) as day,
	EXTRACT (week from payment_date) as week,
	CASE WHEN EXTRACT (ISODOW FROM payment_date) IN (6,7) THEN true ELSE false END AS is_weekend
FROM payment;


INSERT INTO dimCustomer
(customer_key,customer_id,first_name,last_name,email,address,address2,district,city,country,postal_code,phone,active,create_date,start_date,end_date)
SELECT
	c.customer_id as customer_key,
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	a.address,
	a.address2,
	a.district,
	ct.city,
	co.country,
	a.postal_code,
	a.phone,
	c.active,
	c.create_Date,
	now() as start_date,
	now() as end_date
FROM customer c
JOIN address a ON (c.address_id =a.address_id)
JOIN city ct ON (a.city_id= ct.city_id)
JOIN country co ON (co.country_id= ct.country_id);

select * from dimCustomer;

INSERT INTO dimStore
(store_key,store_id,address,address2,district,city,country,postal_code,manager_first_name,manager_last_name,start_date,end_date)
SELECT
	s.store_id as store_key,
	s.store_id,
	a.address,
	a.address2,
	a.district,
	ct.city,
	co.country,
	a.postal_code,
	st.first_name as manager_first_name,
	st.last_name as manager_last_name,
	now() as start_date,
	now() as end_date
	
FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city ct ON(ct.city_id =a.city_id )
JOIN country co ON (co.country_id=ct.country_id)
JOIN staff st ON (st.store_id= s.store_id);

select * from dimStore

INSERT INTO dimFilm
(film_key,film_id,title,description,release_year,language,original_language,rental_duration,length,ratings,special_features)
SELECT
f.film_id as film_key,
f.film_id,
f.title,
f.description,
f.release_year,
l.name as language,
l.name as original_language,
f.rental_duration,
f.length,
f.rating as ratings,
f.special_features
FROM film f
JOIN language l ON (l.language_id= f.language_id);

select * from dimFilm;



CREATE TABLE factSales
(
	sales_key SERIAL PRIMARY KEY,
	date_key integer REFERENCES dimDate (date_key),
	customer_key integer REFERENCES dimCustomer (customer_key),
	film_key integer REFERENCES dimFilm (film_key),
	store_key integer REFERENCES dimStore (store_key),
	sales_amount numeric
);

INSERT INTO factSales
(date_key,customer_key,film_key,store_key,sales_amount)
SELECT
TO_CHAR (payment_date :: DATE ,'yyMMDD')::integer as date_key,
p.customer_id as customer_key,
i.film_id as film_key,
i.store_id as store_key,
p.amount as sales_amount
FROM payment p
JOIN rental r ON (r.rental_id = p.rental_id)
JOIN inventory i ON (i.inventory_id = r.inventory_id);

select * from factsales;


