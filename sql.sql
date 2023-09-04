--Roles--
create role RoleManager;
create role RoleClient;
create role RoleDevelop;
--Users--
create user Manager password '123';
grant RoleManager to Manager;
create user Client password '123';
grant RoleManager to Client;
create user Develop password '123';
grant RoleDevelop to Develop;

--Prev to Manager--
GRANT EXECUTE ON PROCEDURE add_mobile TO RoleManager;
GRANT EXECUTE ON PROCEDURE update_mobile TO RoleManager;
GRANT EXECUTE ON PROCEDURE delete_mobile TO RoleManager;
GRANT EXECUTE ON FUNCTION  show_mobile TO RoleManager;
GRANT EXECUTE ON FUNCTION ANALIZE TO RoleManager;
GRANT EXECUTE ON FUNCTION  search_mobile_by_brend TO RoleManager;
GRANT EXECUTE ON FUNCTION  search_mobile_by_name TO RoleManager;
GRANT EXECUTE ON FUNCTION  show_review_to_mobile TO RoleManager;

--Prev to Develop--
grant connect on database "Kursach" to RoleDevelop;
GRANT ALL ON SCHEMA public TO RoleDevelop;
grant all privileges on database "Kursach" to RoleDevelop;
grant all privileges on tablespace TS_USER to RoleDevelop;
grant all privileges on tablespace TS_TOVAR to RoleDevelop;


--Prev to Client--
GRANT EXECUTE ON PROCEDURE add_mobile_to_basket TO RoleClient;
GRANT EXECUTE ON PROCEDURE add_mobile_to_favourites TO RoleClient;
GRANT EXECUTE ON PROCEDURE add_review_to_mobile TO RoleClient;
GRANT EXECUTE ON PROCEDURE delete_mobile_count_basket TO RoleClient;
GRANT EXECUTE ON PROCEDURE delete_mobile_from_basket TO RoleClient;
GRANT EXECUTE ON PROCEDURE delete_mobile_from_favourites TO RoleClient;
GRANT EXECUTE ON PROCEDURE delete_review_to_mobile TO RoleClient;
GRANT EXECUTE ON PROCEDURE update_review_to_mobile TO RoleClient;
GRANT EXECUTE ON PROCEDURE purchaise TO RoleClient;
GRANT EXECUTE ON PROCEDURE purchaise TO RoleClient;
GRANT EXECUTE ON FUNCTION  search_mobile_by_brend TO RoleClient;
GRANT EXECUTE ON FUNCTION  search_mobile_by_name TO RoleClient;
GRANT EXECUTE ON FUNCTION  show_mobile TO RoleClient;
GRANT EXECUTE ON FUNCTION  show_review_to_mobile TO RoleClient;
GRANT EXECUTE ON FUNCTION  show_favourites TO RoleClient;
GRANT EXECUTE ON FUNCTION  show_basket TO RoleClient;

--Tablespaces--
create tablespace TS_USER 
location 'D:\BDKURSACH\TS_USER';
create tablespace TS_TOVAR 
location 'D:\BDKURSACH\TS_TOVAR';

--Tables--
create table Client(
client_id serial primary key
) tablespace TS_USER;

create table Basket(
	id_mobile serial,
	counter int check (counter=0 or counter >0),
	client_id serial, 
		constraint FK_Basket_Mobile foreign key (id_mobile) references Mobile(id_mobile),
		constraint FK_Basket_Client foreign key (client_id) references Client(client_id)
) tablespace TS_USER;

create table Mobile(
id_mobile serial primary key,
	mobile_name varchar(100) not null,
	mobile_price int not null check (mobile_price>0),
	mobile_brend varchar(100) check (mobile_brend='Samsung' or 
									mobile_brend='Apple' or
									mobile_brend='Xiaomi'),
	mobile_os varchar(100) not null check (mobile_os='Android' or
										mobile_os='iOS'),
	mobile_date int not null
) tablespace TS_TOVAR;

create table Ordert(
id_ordert serial primary key,
	client_id serial not null,
	client_name varchar(100) not null,
	client_phone varchar(20) not null,
	date_order TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	address_order varchar(100) not null,
	information_order text not null,
	all_count int not null,
	all_price int not null,
	constraint FK_Ordert_Client foreign key (client_id) references Client(client_id)
) tablespace TS_TOVAR;
alter table Favorites add column id_favorites serial primary key
create table Favorites(
	id_favorites setial primary key,
	id_mobile serial not null,
	client_id serial not null, 
		constraint FK_Favorites_Mobile foreign key (id_mobile) references Mobile(id_mobile),
		constraint FK_Favorites_Client foreign key (client_id) references Client(client_id)
) tablespace TS_USER;

create table Reviews(
	id_review serial primary key,
	id_mobile serial not null,
	client_id serial not null, 
	description text not null,
		constraint FK_Reviews_Mobile foreign key (id_mobile) references Mobile(id_mobile),
		constraint FK_Reviews_Client foreign key (client_id) references Client(client_id)
) tablespace TS_TOVAR;

CREATE INDEX idx_mob ON Mobile(mobile_name);

----------------
----Телефоны----
----------------
--Создание функции добавления товара--
CREATE OR REPLACE PROCEDURE ADD_MOBILE(mobile_name_arg varchar(100),mobile_price_arg int,mobile_brend_arg varchar(100),
mobile_os_arg varchar(100), mobile_date_arg int)
AS $$
DECLARE
mobile_id_add INTEGER;
BEGIN
INSERT INTO Mobile(mobile_name,mobile_price,mobile_brend,mobile_os ,mobile_date)
VALUES(mobile_name_arg,mobile_price_arg,mobile_brend_arg,mobile_os_arg,mobile_date_arg);
update Mobile set text_tsv = to_tsvector('russian',mobile_name);
END;
$$ LANGUAGE PLPGSQL;
call ADD_MOBILE('Самсунг',4028,'Apple','iOS',2018);
select * from Mobile;

--Создание функции обновления товара--
CREATE OR REPLACE PROCEDURE UPDATE_MOBILE(
	id_mobile_arg int,
  mobile_name_arg varchar(100),
  mobile_price_arg int,
  mobile_brend_arg varchar(100),
	mobile_os_arg varchar(100),
	mobile_date_arg int
) LANGUAGE PLPGSQL AS $$
BEGIN
    UPDATE Mobile
    SET
      mobile_name = mobile_name_arg,
	  mobile_price=mobile_price_arg,
	  mobile_brend=mobile_brend_arg,
	  mobile_os=mobile_os_arg,
	  mobile_date=mobile_date_arg
    WHERE Mobile.id_mobile = id_mobile_arg;
END;
$$;
call UPDATE_MOBILE(4,'Samsung Galaxy A54 5G',777,'Samsung','Android',2023)
select * from Mobile

--Создание функции удаления товара из магазина--
CREATE OR REPLACE PROCEDURE DELETE_MOBILE( mobile_id_arg INTEGER) LANGUAGE PLPGSQL AS $$
BEGIN
    DELETE FROM Basket WHERE Basket.id_mobile = mobile_id_arg;
    DELETE FROM Mobile WHERE Mobile.id_mobile = mobile_id_arg;
END;
$$;
call DELETE_MOBILE(7);
select * from Mobile;

--Создание функции для просмотра телефонов--
CREATE OR REPLACE FUNCTION SHOW_MOBILE()
RETURNS TABLE(
	id_mobile_arg int,
	  mobile_name_arg varchar(100),
	  mobile_price_arg integer,
	  mobile_brend_arg varchar(100),
	  mobile_os_arg varchar(100),
	  mobile_date_arg int
  ) as $$ 
  begin 
  RETURN QUERY
  SELECT id_mobile,mobile_name,mobile_price,mobile_brend,mobile_os,mobile_date FROM Mobile;
  end
  $$ language PLPGSQL;
drop function SHOW_MOBILE
select * from SHOW_MOBILE()

---------------
----Корзина----
---------------
--Создание функции добавления товара в корзину--
CREATE OR REPLACE PROCEDURE ADD_MOBILE_TO_BASKET(
    mobile_id_arg INTEGER,
	client_id_arg int
)
LANGUAGE PLPGSQL
AS $$
declare hh int;
BEGIN
hh = (select count(id_mobile) from Basket where id_mobile = mobile_id_arg
	 and client_id = client_id_arg);
if hh = 0 then
    INSERT INTO Basket(id_mobile,client_id,counter)
    VALUES (mobile_id_arg,client_id_arg,1);
elseif hh > 0 then
	update Basket set counter = counter + 1 where id_mobile = mobile_id_arg
	and client_id = client_id_arg;
END if;
end;
$$;
delete from Basket
select * from Basket
select * from Client
call ADD_MOBILE_TO_BASKET(5,1)

--Уменьшение количесвтва товаров в корзине--
CREATE OR REPLACE PROCEDURE DELETE_MOBILE_COUNT_BASKET(mobile_id_arg INTEGER,
													  client_id_arg int) 
LANGUAGE PLPGSQL AS $$
declare hh int;
BEGIN
hh = (select counter from Basket where id_mobile = mobile_id_arg
	 and client_id=client_id_arg);
if hh > 1 then
	update Basket set counter = counter - 1 where id_mobile = mobile_id_arg
	and client_id=client_id_arg;
elseif hh = 1 then
RAISE EXCEPTION 'Ошибка: минимальное количество товара в корзине';
end if;
END;
$$;
call DELETE_MOBILE_COUNT_BASKET(4,1)
select * from Basket

--Удаление товара из корзины--
CREATE OR REPLACE PROCEDURE DELETE_MOBILE_FROM_BASKET( mobile_id_arg INTEGER,
													 client_id_arg int) 
LANGUAGE PLPGSQL AS $$
BEGIN
    DELETE FROM Basket WHERE id_mobile = mobile_id_arg
	and client_id=client_id_arg;
END;
$$;
call DELETE_MOBILE_FROM_BASKET(4,1)
--Создание функции для просмотра корзины--
CREATE OR REPLACE FUNCTION SHOW_BASKET(client_id_arg int)
RETURNS TABLE(
	id_basket_arg int,
	id_mobile_arg int,
	  client_id_ar int,
	  counter_ar int
  ) as $$ 
  begin 
  RETURN QUERY
  SELECT id_basket,id_mobile,client_id,counter FROM Basket where client_id = client_id_arg;
  end
  $$ language PLPGSQL;
  drop function SHOW_BASKET
select * from SHOW_BASKET(1)

-----------------
----Избранное----
-----------------

--Создание функции добавленяи телефона в избранное--
CREATE OR REPLACE PROCEDURE add_mobile_to_favourites(
	mobile_id_arg integer,
	client_id_arg integer)
LANGUAGE 'plpgsql'
AS $$
declare hh int;
BEGIN
hh = (select count(id_mobile) from Favorites where id_mobile = mobile_id_arg
	 and client_id=client_id_arg);
if hh = 0 then
    INSERT INTO Favorites(id_mobile,client_id)
    VALUES (mobile_id_arg,client_id_arg);
elseif hh > 0 then
	RAISE EXCEPTION 'Ошибка: товар уже добавлен в избранное';
END if;
end;
$$;
call add_mobile_to_favourites(4,2)

--Создание функции для просмотра избранное--
CREATE OR REPLACE FUNCTION SHOW_FAVOURITES(client_id_arg int)
RETURNS TABLE(
	id_favorites_arg int,
	id_mobile_arg int,
	  client_id_a int
  ) as $$ 
  begin 
  RETURN QUERY
  SELECT id_favorites,id_mobile,client_id FROM Favorites where client_id = client_id_arg;
  end
  $$ language PLPGSQL;
  drop function SHOW_FAVOURITES
select * from SHOW_FAVOURITES(1)
select * from Favorites

--Удаление товара из избранных--
CREATE OR REPLACE PROCEDURE DELETE_MOBILE_FROM_FAVOURITES(mobile_id_arg INTEGER,
														 client_id_arg int) 
LANGUAGE PLPGSQL AS $$
BEGIN
    DELETE FROM Favorites WHERE id_mobile = mobile_id_arg 
	and client_id = client_id_arg;
END;
$$;
call DELETE_MOBILE_FROM_FAVOURITES(4,2)


--------------
----Отзывы----
--------------
--Создание функции добавления отзыва телефону--
CREATE OR REPLACE PROCEDURE add_review_to_mobile(
	mobile_id_arg integer,
	client_id_arg integer,
	description_arg character varying)
LANGUAGE 'plpgsql'
AS $$
declare hh int;
BEGIN
hh = (select count(id_mobile) from Reviews where id_mobile =mobile_id_arg
	and  client_id = client_id_arg);
if hh = 0 then
    INSERT INTO Reviews(id_mobile,client_id,description)
    VALUES (mobile_id_arg,client_id_arg,description_arg);
elseif hh > 0 then
	RAISE EXCEPTION 'Ошибка: нельзя добавить больше 1 отзыва к товару';
END if;
end;
$$;
call add_review_to_mobile(5,2,'Крутой')
select * from Reviews

--Создание функции редактирования отзыва у телефона--
CREATE OR REPLACE PROCEDURE update_review_to_mobile(
	mobile_id_arg integer,
	client_id_arg integer,
	description_arg character varying)
LANGUAGE 'plpgsql'
AS $$
declare hh int;
BEGIN
hh = (select count(id_mobile) from Reviews where id_mobile =mobile_id_arg
	and  client_id = client_id_arg);
if hh = 0 then
   	RAISE EXCEPTION 'Ошибка: нету такого отзыва';
elseif hh > 0 then
update Reviews set description = description_arg 
where id_mobile =mobile_id_arg
	and  client_id = client_id_arg;
END if;
end;
$$;
call update_review_to_mobile(6,1,'Не оч')

--Создание функции удаления отзыва у телефона--
CREATE OR REPLACE PROCEDURE delete_review_to_mobile(
	mobile_id_arg integer,
	client_id_arg integer)
LANGUAGE 'plpgsql'
AS $$
declare hh int;
BEGIN
hh = (select count(id_mobile) from Reviews where id_mobile =mobile_id_arg
	and  client_id = client_id_arg);
if hh = 0 then
   	RAISE EXCEPTION 'Ошибка: нету такого отзыва';
elseif hh > 0 then
delete from Reviews where id_mobile =mobile_id_arg
	and  client_id = client_id_arg;
END if;
end;
$$;
call delete_review_to_mobile(5,1)

--Создание функции просмотра отзыва у телефона--
CREATE OR REPLACE function show_review_to_mobile(
	mobile_id_arg integer)
	RETURNS TABLE(
  mobile_id_ar integer,
  client_id_arg integer,
  description_arg varchar(100)
)
LANGUAGE 'plpgsql'
AS $$
BEGIN
RETURN QUERY
select id_mobile, client_id, description from Reviews
where id_mobile=mobile_id_arg;
end;
$$;
drop function show_review_to_mobile
select * from show_review_to_mobile(5)

--------------
----Другие----
--------------
--Создание функции поиска товара по названию--
CREATE or replace FUNCTION SEARCH_MOBILE_BY_NAME(mobile_name_arg varchar(100))
RETURNS TABLE(
  mobile_name varchar(100),
  mobile_price integer,
  mobile_brend varchar(100),
  mobile_os varchar(100),
  mobile_date int	  
) as $$ 
begin 
RETURN QUERY
select MOBILE_INFO.mobile_name,MOBILE_INFO.mobile_price,
MOBILE_INFO.mobile_brend, MOBILE_INFO.mobile_os,
MOBILE_INFO.mobile_date FROM MOBILE_INFO where MOBILE_INFO.text_tsv @@
plainto_tsquery('russian',mobile_name_arg);
end;
$$ language PLPGSQL;
  drop function SEARCH_MOBILE_BY_NAME;
  select * from SEARCH_MOBILE_BY_NAME('о Самсунгах');
  select * from Mobile;

--Создание функции поиска товара по категории--
CREATE or replace FUNCTION SEARCH_MOBILE_BY_BREND(mobile_brend_arg varchar(100))
RETURNS TABLE(
  mobile_name varchar(100),
  mobile_price integer,
  mobile_brend varchar(100),
  mobile_os varchar(100),
  mobile_date int
) as $$ 
begin 
if mobile_brend_arg='Samsung' or mobile_brend_arg='Xiaomi' 
or mobile_brend_arg='Apple' then
RETURN QUERY
SELECT MOBILE_INFO.mobile_name,MOBILE_INFO.mobile_price,
MOBILE_INFO.mobile_brend, MOBILE_INFO.mobile_os,
MOBILE_INFO.mobile_date FROM MOBILE_INFO  
where MOBILE_INFO.mobile_brend  like '%'|| mobile_brend_arg || '%';
elseif mobile_brend_arg!='Samsung' or mobile_brend_arg!='Xiaomi' 
or mobile_brend_arg!='Apple' then
RAISE EXCEPTION 'Ошибка: неверное название бренда';
end if;
end;
$$ language PLPGSQL;
drop function SEARCH_MOBILE_BY_BREND;
select * from SEARCH_MOBILE_BY_BREND('Apple');
select * from Product;
select * from Product_info

--Создание функции офрмления заказа--
  CREATE OR REPLACE PROCEDURE PURCHAISE(
	id_client_arg INTEGER,
	client_name_arg varchar(100),
	client_phone_arg varchar(20),
	address_order_arg TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
information_f1 TEXT;
information_f2 TEXT;
all_count int;
all_price int;
chec int;
BEGIN
  chec = (select count(counter) from Basket 
			  where client_id=id_client_arg);
  all_count = (select sum(counter) from Basket 
			  where client_id=id_client_arg);
  all_price = (select sum(mobile_price*counter) from Basket join
			  Mobile on Basket.id_mobile = Mobile.id_mobile
			  where client_id=id_client_arg);
			  if chec = 0 then
			  RAISE EXCEPTION 'Ошибка: в корзине нету товаров';
			  elseif chec > 0 then
SELECT string_agg(mobile_name || '(' || counter || ')', ', ') INTO information_f1 
FROM Basket join Mobile on Basket.id_mobile = Mobile.id_mobile
WHERE client_id = id_client_arg and counter > 1;
SELECT string_agg(mobile_name, ', ') INTO information_f2 FROM Basket 
join Mobile on Basket.id_mobile = Mobile.id_mobile
WHERE client_id = id_client_arg and counter = 1;

INSERT INTO Ordert (client_id, client_name, client_phone, address_order, 
					information_order, all_count, all_price)
VALUES (id_client_arg, 
		client_name_arg, 
		client_phone_arg, 
		address_order_arg, 
		concat_ws(', ',information_f1, information_f2),
	    all_count, 
	    all_price);

DELETE FROM Basket WHERE client_id = id_client_arg;
end if;
END;
$$;
select * from Basket
call ADD_MOBILE_TO_BASKET(5,2)
call PURCHAISE(2,'Павел','+343245324332','Г Минск')
select * from Ordert 
delete from Ordert
select * from ordert_info 

 --Создание функции для анализа заказов--
CREATE or replace FUNCTION ANALIZE()
RETURNS TABLE(
	Все_проданные_товары bigint,
	Общая_выручка bigint 
) as $$
declare cont text; 
begin
RETURN QUERY	
select sum(all_count), sum(all_price) from ordert_info;
end;
$$ language PLPGSQL;

select * from ANALIZE()
drop function ANALIZE
--Создание функции для заполнения 100000 строк--

CREATE OR REPLACE FUNCTION INSERT_MOBILE()
RETURNS VOID AS $$
DECLARE
I INTEGER := 1;
BEGIN
WHILE I <= 100000 LOOP
	INSERT INTO Mobile (mobile_name,mobile_price,mobile_brend,mobile_os,
			  mobile_date) values('Samsung',I,'Samsung','Android',2015);
	I := I + 1;
END LOOP;
update Mobile set text_tsv = to_tsvector('russian',mobile_name);
END;
$$ LANGUAGE PLPGSQL;
drop FUNCTION INSERT_MOBILE
select INSERT_MOBILE()
select mobile_name from Mobile where mobile_name='Samsung'

---Процедура входа на сервис---
CREATE OR REPLACE PROCEDURE ENTERING()
AS $$
DECLARE
BEGIN
INSERT INTO Client default values;
END;
$$ LANGUAGE PLPGSQL;
call ENTERING()

-------------Индексы--------
CREATE INDEX idx_mob ON Mobile(mobile_name);
CREATE INDEX idx_mob_id ON Mobile(id_mobile);
CREATE INDEX idx_id_ordert ON Ordert(id_ordert);
create index if not exists idx_tsv_mobile_name on Mobile using gin(text_tsv)
drop INDEX idx_mob
drop INDEX idx_mob_id
drop INDEX idx_tsv_mobile_name



-----------------------------------
-------------ПРЕДСТАВЛЕНИЯ---------
-----------------------------------
 
 --Представление с информацией о товаре--
CREATE VIEW MOBILE_INFO AS
SELECT p.mobile_name,
p.mobile_price,
p.mobile_brend,
p.mobile_os,
p.mobile_date,
p.text_tsv
FROM MOBILE p
 drop view MOBILE_INFO;
 select * from MOBILE_INFO;
--Представление с информацией о заказах--
CREATE OR REPLACE VIEW public.ordert_info
AS
SELECT o.id_ordert,
o.client_id,
o.client_name,
o.client_phone,
o.date_order,
o.address_order,
o.information_order,
o.all_count,
o.all_price
FROM ordert o;
	 
  
------------- Триггеры -----------------
----------------------------------------
----------------------------------------

--Создание триггера, реагирующего на корректный ввод имени--
CREATE FUNCTION FUNC_FOR_custom_name() RETURNS TRIGGER AS $$
BEGIN
    IF length(NEW.client_name) < 2 THEN
        RAISE EXCEPTION 'Имя должно содержать минимум 2 символа';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
drop FUNCTION FUNC_FOR_custom_name cascade
CREATE or replace TRIGGER TR_custom_name
BEFORE INSERT OR UPDATE
ON Ordert
FOR EACH ROW EXECUTE FUNCTION FUNC_FOR_custom_name();

--Создание триггера, реагирующий на корректность номера телефона--
CREATE FUNCTION FUNC_FOR_custom_phone() RETURNS TRIGGER AS $$
BEGIN
  IF CHAR_LENGTH(NEW.client_phone) < 13 or CHAR_LENGTH(NEW.client_phone)>13  THEN
    RAISE EXCEPTION 'Телефон должен содеражть 13 символов';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TR_custom_phone
  BEFORE INSERT OR UPDATE ON Ordert
  FOR EACH ROW
  EXECUTE FUNCTION FUNC_FOR_custom_phone();

--Создание триггера, реагирующий на корректность адреса--
CREATE FUNCTION FUNC_FOR_address_order() RETURNS TRIGGER AS $$
BEGIN
  IF CHAR_LENGTH(NEW.address_order) < 5  THEN
    RAISE EXCEPTION 'Адрес должен быть больше 4 символов';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TR_address_order
  BEFORE INSERT OR UPDATE ON Ordert
  FOR EACH ROW
  EXECUTE FUNCTION FUNC_FOR_address_order();
  
----Технология----
select * from Ordert, Mobile where information_order @@
plainto_tsquery('russian',Mobile.mobile_name)




--------------— Функция экспорта данных в XML
CREATE EXTENSION adminpack;
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE OR REPLACE FUNCTION public.export_orders_to_xml_file(
file_path text)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
xml_data xml;
xml_doc text;
BEGIN
SELECT table_to_xml('Mobile', true, false, '') INTO xml_data;

xml_doc := format('<?xml version="1.0" encoding="UTF-8"?>%s', xml_data::text);

PERFORM pg_file_write(file_path, xml_doc, true);
END;
$BODY$;

ALTER FUNCTION public.export_orders_to_xml_file(text)
OWNER TO roledevelop;


SELECT export_orders_to_xml_file('D:/BDKURSACH/export.xml');

--------------— Функция импорта данных из XML
CREATE OR REPLACE FUNCTION import_data_from_xml()
RETURNS VOID AS
$$
DECLARE
xml_data XML;
BEGIN
SELECT XMLPARSE(DOCUMENT convert_from(pg_read_binary_file('D:/BDKURSACH/export.xml'), 'UTF8'))
INTO xml_data;

END;
$$
LANGUAGE plpgsql;


SELECT import_data_from_xml();



call ADD_MOBILE('Самсунг',4028,'Apple','iOS',2018);
call UPDATE_MOBILE(4,'Samsung Galaxy A54 5G',777,'Samsung','Android',2023)
select * from SHOW_MOBILE()
call DELETE_MOBILE(7);

call ADD_MOBILE_TO_BASKET(5,1)
call DELETE_MOBILE_COUNT_BASKET(4,1)
call DELETE_MOBILE_FROM_BASKET(4,1)
select * from SHOW_BASKET(1)

call add_mobile_to_favourites(4,2)
select * from SHOW_FAVOURITES(1)
call DELETE_MOBILE_FROM_FAVOURITES(4,2)

call add_review_to_mobile(5,2,'Крутой')
call update_review_to_mobile(6,1,'Не оч')
call delete_review_to_mobile(5,1)
select * from show_review_to_mobile(5)








