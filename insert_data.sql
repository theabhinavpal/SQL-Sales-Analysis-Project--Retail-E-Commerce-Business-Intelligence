-- =====================================================================
-- File        : insert_data.sql
-- Project      : SQL Sales Analysis Project (Retail E-Commerce)
-- Description  : Populates customers, products, and orders tables using
--                the accompanying CSV files (customers.csv, products.csv,
--                orders.csv). Total: 850 customers, 58 products, 5,200+
--                order line items spanning Jan 2023 - Dec 2024.
-- Notes        : Data was generated programmatically (see /generator
--                notes at the bottom of this file) to realistically
--                simulate a retail e-commerce business, including
--                deliberate patterns such as seasonal spikes, a
--                Pareto-style customer revenue distribution, and
--                category-level margin differences — the same kind of
--                patterns an analyst would investigate in a real
--                business dataset.
-- =====================================================================

USE sql_sales_analysis;

-- ---------------------------------------------------------------------
-- 1. ALLOW LOCAL FILE LOADING (MySQL client/server setting)
-- ---------------------------------------------------------------------
-- Why: LOAD DATA LOCAL INFILE is disabled by default for security.
-- Run this once per session if your client blocks local file loads.
-- (Skip if your MySQL server already allows it.)

-- SET GLOBAL local_infile = 1;

-- ---------------------------------------------------------------------
-- 2. LOAD customers.csv
-- ---------------------------------------------------------------------
-- Why: Loading via CSV (instead of 850 individual INSERT statements)
-- is the standard, professional approach for bulk data population and
-- mirrors how real ETL pipelines ingest data into a database.

LOAD DATA LOCAL INFILE 'customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_name, gender, age, city, state, region);

-- ---------------------------------------------------------------------
-- 3. LOAD products.csv
-- ---------------------------------------------------------------------

LOAD DATA LOCAL INFILE 'products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, category, sub_category, unit_price);

-- ---------------------------------------------------------------------
-- 4. LOAD orders.csv
-- ---------------------------------------------------------------------
-- Why: order_line_id is loaded explicitly from the CSV (rather than
-- relying purely on AUTO_INCREMENT) to guarantee referential
-- consistency with any pre-generated reporting/screenshot examples.

LOAD DATA LOCAL INFILE 'orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_line_id, order_id, order_date, ship_date, customer_id, product_id,
 quantity, unit_price, discount, sales, cost, profit, payment_mode, shipping_mode);

-- Resync the AUTO_INCREMENT counter after an explicit-ID load.
ALTER TABLE orders AUTO_INCREMENT = 5300;

-- ---------------------------------------------------------------------
-- 5. VERIFICATION
-- ---------------------------------------------------------------------

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products  FROM products;
SELECT COUNT(*) AS total_order_lines FROM orders;

SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order FROM orders;

-- =====================================================================
-- GENERATOR NOTES (for transparency / reproducibility)
-- =====================================================================
-- The three CSV files were generated with a seeded Python script to
-- ensure the dataset is realistic and reproducible:
--   - 850 unique customers across 5 regions / multiple Indian states
--   - 58 unique products across 5 categories / 15 sub-categories
--   - 5,200 order line items across ~3,900 checkouts (Jan 2023-Dec 2024)
--   - Built-in seasonality (Oct-Nov festive spike, Jan new-year bump)
--   - A "VIP" customer segment (15% of customers) weighted to generate
--     a disproportionate share of orders (Pareto-style distribution)
--   - Category/sub-category and region-based margin differences to
--     produce realistic, analyzable profit patterns
-- The generation script is not required to run the project (the CSVs
-- are provided directly) but is available on request for full
-- transparency on how the synthetic dataset was constructed.
-- =====================================================================
