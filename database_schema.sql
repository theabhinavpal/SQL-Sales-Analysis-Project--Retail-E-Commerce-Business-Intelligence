-- =====================================================================
-- File        : database_schema.sql
-- Project      : SQL Sales Analysis Project (Retail E-Commerce)
-- Description  : Creates the database and a normalized 3-table schema
--                (customers, products, orders) with primary keys,
--                foreign keys, constraints, and performance indexes.
-- Author       : Data Analyst Portfolio Project
-- Notes        : Written for MySQL 8.0. Postgres-specific notes are
--                added inline (##) wherever syntax differs.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. DATABASE CREATION
-- ---------------------------------------------------------------------
-- Why: A dedicated database keeps this project isolated from other
-- schemas on the same server, which is standard practice before
-- building any analytics project.

DROP DATABASE IF EXISTS sql_sales_analysis;
CREATE DATABASE sql_sales_analysis
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;              -- ## Postgres: omit this line, use CREATE DATABASE sql_sales_analysis; then set encoding at cluster level

USE sql_sales_analysis;

-- ---------------------------------------------------------------------
-- 2. DESIGN NOTES (NORMALIZATION)
-- ---------------------------------------------------------------------
-- The raw dataset described in the brief is a single flat table
-- (Order_ID, Customer_Name, Product_Name, City, State, Category, ...).
-- For a professional portfolio project, we normalize this into three
-- related tables to avoid repeating customer/product attributes on
-- every single order row:
--
--   customers  -> one row per unique customer
--   products   -> one row per unique product
--   orders     -> one row per order line, referencing customers/products
--
-- This mirrors how a real OLTP-style e-commerce database is designed,
-- and lets us demonstrate JOINs meaningfully instead of querying one
-- wide table. A denormalized "flat" version can still be generated
-- with a JOIN + VIEW (see sales_analysis.sql -> vw_sales_flat).

-- ---------------------------------------------------------------------
-- 3. TABLE: customers
-- ---------------------------------------------------------------------
-- Why: Stores unique customer demographic and location data once,
-- instead of repeating it on every order (reduces redundancy,
-- avoids update anomalies e.g. a customer's city changing).

CREATE TABLE customers (
    customer_id     VARCHAR(10)     NOT NULL,
    customer_name   VARCHAR(100)    NOT NULL,
    gender          VARCHAR(10)     NOT NULL,
    age             TINYINT UNSIGNED NOT NULL,
    city            VARCHAR(50)     NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    region          VARCHAR(20)     NOT NULL,

    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT chk_customer_age CHECK (age BETWEEN 12 AND 100),
    CONSTRAINT chk_customer_gender CHECK (gender IN ('Male', 'Female', 'Other'))
);

-- ---------------------------------------------------------------------
-- 4. TABLE: products
-- ---------------------------------------------------------------------
-- Why: Stores unique product catalog data once. Unit_Price lives here
-- as the catalog list price; the actual transaction price/discount is
-- captured per order line in the orders table (prices can be
-- discounted differently per order).

CREATE TABLE products (
    product_id      VARCHAR(10)     NOT NULL,
    product_name    VARCHAR(150)    NOT NULL,
    category        VARCHAR(50)     NOT NULL,
    sub_category     VARCHAR(50)     NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,

    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT chk_unit_price CHECK (unit_price > 0)
);

-- ---------------------------------------------------------------------
-- 5. TABLE: orders
-- ---------------------------------------------------------------------
-- Why: This is the transactional fact table — one row per order line
-- item. It references customers and products via foreign keys and
-- stores the financial outcome of the transaction (sales, cost,
-- profit), which is what most business questions are analyzed against.

CREATE TABLE orders (
    order_line_id   INT             NOT NULL AUTO_INCREMENT,  -- ## Postgres: use GENERATED ALWAYS AS IDENTITY
    order_id        VARCHAR(15)     NOT NULL,
    order_date      DATE            NOT NULL,
    ship_date       DATE            NOT NULL,
    customer_id     VARCHAR(10)     NOT NULL,
    product_id      VARCHAR(10)     NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,   -- price at time of sale (may differ from catalog price)
    discount        DECIMAL(4,2)    NOT NULL DEFAULT 0.00,  -- stored as a fraction, e.g. 0.15 = 15%
    sales            DECIMAL(12,2)   NOT NULL,   -- final revenue for this line = qty * unit_price * (1 - discount)
    cost            DECIMAL(12,2)   NOT NULL,   -- total cost of goods for this line
    profit          DECIMAL(12,2)   NOT NULL,   -- sales - cost
    payment_mode    VARCHAR(30)     NOT NULL,
    shipping_mode   VARCHAR(30)     NOT NULL,

    CONSTRAINT pk_orders PRIMARY KEY (order_line_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_orders_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_discount CHECK (discount BETWEEN 0 AND 0.80),
    CONSTRAINT chk_ship_after_order CHECK (ship_date >= order_date),
    CONSTRAINT chk_payment_mode CHECK (
        payment_mode IN ('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash on Delivery', 'Wallet')
    ),
    CONSTRAINT chk_shipping_mode CHECK (
        shipping_mode IN ('Standard', 'Express', 'Same Day', 'Economy')
    )
);

-- Why order_id is NOT the primary key of orders:
-- A single Order_ID (one customer "order") can legally contain multiple
-- line items (e.g., a customer buys 3 different products in one
-- checkout). order_line_id is the true unique row identifier, while
-- order_id groups related line items together — exactly like real
-- e-commerce order systems (Amazon, Flipkart, etc).

-- ---------------------------------------------------------------------
-- 6. INDEXES FOR QUERY PERFORMANCE
-- ---------------------------------------------------------------------
-- Why: These indexes support the most common filter/join/group-by
-- patterns used throughout sales_analysis.sql (date range filters,
-- joins to customers/products, and grouping by region/category).

CREATE INDEX idx_orders_customer_id   ON orders(customer_id);
CREATE INDEX idx_orders_product_id    ON orders(product_id);
CREATE INDEX idx_orders_order_date    ON orders(order_date);
CREATE INDEX idx_orders_order_id      ON orders(order_id);

CREATE INDEX idx_customers_region     ON customers(region);
CREATE INDEX idx_customers_state      ON customers(state);

CREATE INDEX idx_products_category    ON products(category);
CREATE INDEX idx_products_subcategory ON products(sub_category);

-- Composite index to speed up common "sales trend by date + region"
-- style queries that filter on date and join to customers/region.
CREATE INDEX idx_orders_date_customer ON orders(order_date, customer_id);

-- ---------------------------------------------------------------------
-- 7. VERIFICATION
-- ---------------------------------------------------------------------
-- Quick sanity check queries to confirm the schema was created correctly.

SHOW TABLES;
DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;
