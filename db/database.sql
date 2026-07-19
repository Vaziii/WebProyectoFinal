-- Grupo 7 - WebProyectoFinal
-- Script SQL de estructura para PostgreSQL.
-- Para ejecucion normal del proyecto se recomienda:
-- bundle exec rails db:create db:migrate db:seed

CREATE EXTENSION IF NOT EXISTS plpgsql;

DROP TABLE IF EXISTS receipt_items CASCADE;
DROP TABLE IF EXISTS receipts CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE categories (
  id bigserial PRIMARY KEY,
  name varchar NOT NULL,
  description text,
  created_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX index_categories_on_lower_name
ON categories (LOWER(name));

CREATE TABLE users (
  id bigserial PRIMARY KEY,
  first_name varchar(80) NOT NULL,
  last_name varchar(80) NOT NULL,
  email varchar(255) NOT NULL,
  password_digest varchar NOT NULL,
  address varchar(255),
  phone_number varchar(20),
  created_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  role varchar NOT NULL DEFAULT 'usuario',
  CONSTRAINT users_role_valid CHECK (role IN ('usuario', 'admin'))
);

CREATE UNIQUE INDEX index_users_on_lower_email
ON users (LOWER(email));

CREATE INDEX index_users_on_role
ON users (role);

CREATE TABLE products (
  id bigserial PRIMARY KEY,
  name varchar NOT NULL,
  description text,
  price decimal(10, 2) NOT NULL,
  stock integer NOT NULL DEFAULT 0,
  category_id bigint,
  created_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT products_price_positive CHECK (price > 0),
  CONSTRAINT products_stock_non_negative CHECK (stock >= 0),
  CONSTRAINT fk_products_categories
    FOREIGN KEY (category_id)
    REFERENCES categories(id)
);

CREATE INDEX index_products_on_name
ON products (name);

CREATE INDEX index_products_on_category_id
ON products (category_id);

CREATE TABLE receipts (
  id bigserial PRIMARY KEY,
  user_id bigint NOT NULL,
  total decimal(12, 2) NOT NULL DEFAULT 0,
  amount_of_items integer NOT NULL DEFAULT 0,
  created_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT receipts_total_non_negative CHECK (total >= 0),
  CONSTRAINT receipts_amount_of_items_positive CHECK (amount_of_items > 0),
  CONSTRAINT fk_receipts_users
    FOREIGN KEY (user_id)
    REFERENCES users(id)
);

CREATE INDEX index_receipts_on_user_id
ON receipts (user_id);

CREATE TABLE receipt_items (
  id bigserial PRIMARY KEY,
  receipt_id bigint NOT NULL,
  product_id bigint NOT NULL,
  quantity integer NOT NULL,
  unit_price decimal(12, 2) NOT NULL,
  subtotal decimal(12, 2) NOT NULL,
  created_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT receipt_items_quantity_positive CHECK (quantity > 0),
  CONSTRAINT receipt_items_unit_price_positive CHECK (unit_price > 0),
  CONSTRAINT receipt_items_subtotal_positive CHECK (subtotal > 0),
  CONSTRAINT fk_receipt_items_receipts
    FOREIGN KEY (receipt_id)
    REFERENCES receipts(id),
  CONSTRAINT fk_receipt_items_products
    FOREIGN KEY (product_id)
    REFERENCES products(id)
);

CREATE INDEX index_receipt_items_on_receipt_id
ON receipt_items (receipt_id);

CREATE INDEX index_receipt_items_on_product_id
ON receipt_items (product_id);

CREATE UNIQUE INDEX index_receipt_items_on_receipt_and_product
ON receipt_items (receipt_id, product_id);

INSERT INTO categories (name, description, created_at, updated_at)
VALUES
  ('Tecnologia', 'Productos electronicos y accesorios.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('Hogar', 'Articulos para uso diario en casa.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO products (name, description, price, stock, category_id, created_at, updated_at)
VALUES
  ('Teclado mecanico', 'Teclado USB con switches mecanicos.', 49.99, 15, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('Mouse inalambrico', 'Mouse ergonomico con conexion 2.4 GHz.', 19.50, 30, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('Termo acero', 'Termo de 750 ml para bebidas frias o calientes.', 12.75, 20, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
