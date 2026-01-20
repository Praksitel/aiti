-- номенклатура
--DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE IF NOT EXISTS products
(
    id SERIAL PRIMARY KEY,
    amount integer NOT NULL,
    price integer NOT NULL,
    name text NOT NULL
);

--DROP TABLE IF EXISTS product_catalog;
CREATE TABLE IF NOT EXISTS product_catalog
(
    id SERIAL PRIMARY KEY,
    parent integer NOT NULL,
	name text NOT NULL
);

--DROP TABLE IF EXISTS product_to_catalog CASCADE;
CREATE TABLE IF NOT EXISTS product_to_catalog
(
    id SERIAL PRIMARY KEY,
    product_id integer NOT NULL REFERENCES products(id),
	catalog_id integer NOT NULL REFERENCES product_catalog(id)
);

--DROP TABLE IF EXISTS clients CASCADE;
CREATE TABLE IF NOT EXISTS clients
(
    id SERIAL PRIMARY KEY,
    name text NOT NULL,
    address text
);

--DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE IF NOT EXISTS orders
(
    id SERIAL PRIMARY KEY,
    client_id integer NOT NULL REFERENCES clients (id),
	dt TIMESTAMP
);

--DROP TABLE IF EXISTS order_items;
CREATE TABLE IF NOT EXISTS order_items
(
    id SERIAL PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders (id),
    item integer NOT NULL REFERENCES products (id),
    count integer NOT NULL DEFAULT 1
);