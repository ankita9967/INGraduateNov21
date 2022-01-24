--section 28
--trigger

--trigger for emplyoee database

ALTER TABLE employees
ADD COLUMN last_updated timestamp;

CREATE OR REPLACE FUNCTION employees_timestamp() RETURNS trigger AS $$
BEGIN

	NEW.last_updated := now();
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

--drop trigger
DROP TRIGGER IF EXISTS employees_timestamp ON employees;

--create trigger
CREATE TRIGGER employees_timestamp BEFORE INSERT OR UPDATE ON employees
	FOR EACH ROW EXECUTE FUNCTION employees_timestamp();

SELECT last_updated,*
FROM employees;

SELECT last_updated,*FROM EMPLOYEES
WHERE employeeid=1;



UPDATE employees
SET address = '27 West Bird Lane'
WHERE employeeid=1;

SELECT last_updated FROM EMPLOYEES
WHERE employeeid=1;


--add a last_updated product table and create function and trigger that uodates the feild every timr

--1)alter the table add column
ALTER TABLE products
ADD COLUMN last_updated timestamp;


--2)create function


CREATE OR REPLACE FUNCTION products_timestamp() RETURNS trigger AS $$
BEGIN

	NEW.last_updated := now();
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

--3)drop trigger


CREATE OR REPLACE FUNCTION products_timestamp() RETURNS trigger AS $$
BEGIN

	NEW.last_updated := now();
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;


--3)drop trigger

DROP TRIGGER IF EXISTS products_timestamp ON products;

--4)create trigger


CREATE TRIGGER products_timestamp BEFORE INSERT OR UPDATE ON products
	FOR EACH ROW EXECUTE FUNCTION products_timestamp();



SELECT last_updated,* FROM products
WHERE productid=2;

UPDATE products
SET unitprice=19.05
WHERE productid=2;

SELECT last_updated,* FROM products
WHERE productid=2;


--statements trigger

--lets create an audit table for order detais and insert changed information into this audit table when insert delete or update happens

-- show how to grab the create statement using pgAdmin


--table created

drop table if exists order_details_audit 

CREATE TABLE order_details_audit (
	operation char(1) NOT NULL,
	userid	text NOT NULL,
	stamp	timestamp NOT NULL,
    orderid smallint NOT NULL,
    productid smallint NOT NULL,
    unitprice real NOT NULL,
    quantity smallint NOT NULL,
    discount real
)

--function created

CREATE OR REPLACE FUNCTION audit_order_details() RETURNS trigger AS $$
BEGIN
	IF (TG_OP == 'DELETE') THEN
		INSERT INTO order_details_audit
		SELECT 'D',user,now(),o.* FROM old_table o;
	ELSIF (TG_OP == 'UPDATE') THEN
		INSERT INTO order_details_audit
		SELECT 'U',user,now(),n.* FROM new_table n;
	ELSIF (TG_OP == 'INSERT') THEN
		INSERT INTO order_details_audit
		SELECT 'U',user,now(),n.* FROM new_table n;
	END IF;
	RETURN NULL;  -- we are using in after trigger so don't need to return update

END;
$$ LANGUAGE plpgsql;

--trigger dropped

DROP TRIGGER IF EXISTS audit_order_details_insert ON order_details;

--trigger created

CREATE TRIGGER audit_order_details_insert AFTER INSERT ON order_details
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_order_details();

--second trigger created

DROP TRIGGER IF EXISTS audit_order_details_update ON order_details;

--trigger created

CREATE TRIGGER audit_order_details_update AFTER UPDATE ON order_details
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_order_details();

--trigger drop

DROP TRIGGER IF EXISTS audit_order_details_delete ON order_details;

--trigger created
CREATE TRIGGER audit_order_details_delete AFTER DELETE ON order_details
REFERENCING OLD TABLE AS old_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_order_details();

INSERT INTO order_details
VALUES (10249, 3, 10, 5, 0);

SELECT * FROM order_details_audit;

update order_details
SET discount=0.20
WHERE orderid=10249 AND productid=3;

SELECT * FROM order_details_audit;

DELETE FROM order_details
WHERE orderid=10249 AND productid=3;

SELECT * FROM order_details_audit;


--create audit trail for order using the same three step of creating table function and trigger

CREATE TABLE orders_audit (
	operation char(1) NOT NULL,
	userid text NOT NULL,
	stamp timestamp NOT NULL,
	orderid smallint NOT NULL,
    customerid bpchar,
    employeeid smallint,
    orderdate date,
    requireddate date,
    shippeddate date,
    shipvia smallint DEFAULT 1,
    freight real,
    shipname character varying(40),
    shipaddress character varying(60),
    shipcity character varying(15),
    shipregion character varying(15),
    shippostalcode character varying(10),
    shipcountry character varying(15)
)

CREATE OR REPLACE FUNCTION audit_orders() RETURNS trigger AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO orders_audit
		SELECT 'I',user,now(),n.* FROM new_table n;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO orders_audit
		SELECT 'U',user,now(),n.* FROM new_table n;
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO orders_audit
		SELECT 'D',user,now(),O.* FROM old_table o;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_orders_insert ON orders;

CREATE TRIGGER audit_orders_insert AFTER INSERT ON orders
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_orders();


DROP TRIGGER IF EXISTS audit_orders_update ON orders;


CREATE TRIGGER audit_orders_update AFTER UPDATE ON orders
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_orders();

DROP TRIGGER IF EXISTS audit_orders_delete ON orders;

CREATE TRIGGER audit_orders_delete AFTER DELETE ON orders
REFERENCING OLD TABLE AS old_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_orders();



INSERT INTO order_details
VALUES (10249, 3, 10, 5, 0);

SELECT * FROM audit_orders;
