-- =====================================================================
-- File        : data_cleaning.sql
-- Project      : SQL Sales Analysis Project (Retail E-Commerce)
-- Description  : Data quality checks and cleaning steps run against
--                the loaded tables before analysis. Even though the
--                provided CSVs are already reasonably clean, this
--                script demonstrates the full professional cleaning
--                workflow an analyst runs on real-world data:
--                duplicate detection, NULL handling, text
--                standardization, and invalid-value checks.
-- =====================================================================

USE sql_sales_analysis;

-- ---------------------------------------------------------------------
-- 1. CHECK FOR DUPLICATE ORDER LINES
-- ---------------------------------------------------------------------
-- Why: Duplicate rows (same order_id + product_id + customer_id
-- appearing more than once) usually indicate an ingestion error and
-- would double-count revenue if left unchecked.

SELECT order_id, product_id, customer_id, COUNT(*) AS occurrences
FROM orders
GROUP BY order_id, product_id, customer_id
HAVING COUNT(*) > 1;

-- If duplicates are found, keep only the first occurrence (lowest
-- order_line_id) and remove the rest:

DELETE o1 FROM orders o1
INNER JOIN orders o2
    ON o1.order_id = o2.order_id
   AND o1.product_id = o2.product_id
   AND o1.customer_id = o2.customer_id
   AND o1.order_line_id > o2.order_line_id;

-- ---------------------------------------------------------------------
-- 2. CHECK FOR DUPLICATE CUSTOMERS / PRODUCTS
-- ---------------------------------------------------------------------
-- Why: A customer or product appearing under two different IDs (e.g.
-- from inconsistent source-system exports) would fragment their
-- purchase history across two rows and understate their true totals.

SELECT customer_name, city, COUNT(DISTINCT customer_id) AS id_count
FROM customers
GROUP BY customer_name, city
HAVING COUNT(DISTINCT customer_id) > 1;

SELECT product_name, category, COUNT(DISTINCT product_id) AS id_count
FROM products
GROUP BY product_name, category
HAVING COUNT(DISTINCT product_id) > 1;

-- ---------------------------------------------------------------------
-- 3. NULL VALUE CHECKS
-- ---------------------------------------------------------------------
-- Why: NULLs in key financial or join columns silently break
-- aggregations and JOINs. We check every critical column across all
-- three tables.

SELECT
    SUM(customer_id IS NULL)   AS null_customer_id,
    SUM(customer_name IS NULL) AS null_customer_name,
    SUM(gender IS NULL)        AS null_gender,
    SUM(age IS NULL)           AS null_age,
    SUM(city IS NULL)          AS null_city,
    SUM(state IS NULL)         AS null_state,
    SUM(region IS NULL)        AS null_region
FROM customers;

SELECT
    SUM(product_id IS NULL)    AS null_product_id,
    SUM(product_name IS NULL)  AS null_product_name,
    SUM(category IS NULL)      AS null_category,
    SUM(sub_category IS NULL)  AS null_sub_category,
    SUM(unit_price IS NULL)    AS null_unit_price
FROM products;

SELECT
    SUM(order_id IS NULL)      AS null_order_id,
    SUM(order_date IS NULL)    AS null_order_date,
    SUM(ship_date IS NULL)     AS null_ship_date,
    SUM(customer_id IS NULL)   AS null_customer_id,
    SUM(product_id IS NULL)    AS null_product_id,
    SUM(quantity IS NULL)      AS null_quantity,
    SUM(sales IS NULL)         AS null_sales,
    SUM(cost IS NULL)          AS null_cost,
    SUM(profit IS NULL)        AS null_profit
FROM orders;

-- Example remediation pattern (if NULLs were found in a non-critical
-- column such as age): impute with the column average rather than
-- dropping the row, to avoid losing otherwise-valid order data.
--
-- UPDATE customers
-- SET age = (SELECT ROUND(AVG(age)) FROM customers WHERE age IS NOT NULL)
-- WHERE age IS NULL;

-- For NULLs in a required financial column (e.g. sales), the row
-- cannot be safely imputed and should be flagged for exclusion:
--
-- DELETE FROM orders WHERE sales IS NULL OR cost IS NULL;

-- ---------------------------------------------------------------------
-- 4. STANDARDIZE TEXT FIELDS
-- ---------------------------------------------------------------------
-- Why: Inconsistent casing/whitespace (e.g. "male" vs "Male ") causes
-- GROUP BY to treat identical categories as different groups, silently
-- fragmenting results.

UPDATE customers
SET gender = TRIM(gender);

UPDATE customers
SET gender = CASE
    WHEN LOWER(gender) IN ('m', 'male') THEN 'Male'
    WHEN LOWER(gender) IN ('f', 'female') THEN 'Female'
    ELSE 'Other'
END;

UPDATE customers SET city  = TRIM(city);
UPDATE customers SET state = TRIM(state);
UPDATE customers SET region = TRIM(region);

UPDATE products SET category     = TRIM(category);
UPDATE products SET sub_category = TRIM(sub_category);
UPDATE products SET product_name = TRIM(product_name);

UPDATE orders SET payment_mode  = TRIM(payment_mode);
UPDATE orders SET shipping_mode = TRIM(shipping_mode);

-- ---------------------------------------------------------------------
-- 5. CHECK FOR INVALID / IMPOSSIBLE VALUES
-- ---------------------------------------------------------------------
-- Why: Negative quantities, zero/negative prices, or ship dates before
-- order dates indicate data-entry or system errors that would distort
-- every downstream revenue calculation.

SELECT * FROM orders WHERE quantity <= 0;
SELECT * FROM orders WHERE unit_price <= 0;
SELECT * FROM orders WHERE discount < 0 OR discount > 1;
SELECT * FROM orders WHERE ship_date < order_date;
SELECT * FROM customers WHERE age < 12 OR age > 100;

-- Example remediation: correct an impossible ship_date by setting it
-- to order_date + 1 (business rule: minimum 1-day processing time)
-- rather than deleting a legitimate order record:
--
-- UPDATE orders
-- SET ship_date = DATE_ADD(order_date, INTERVAL 1 DAY)
-- WHERE ship_date < order_date;

-- ---------------------------------------------------------------------
-- 6. VALIDATE FINANCIAL CONSISTENCY (sales/cost/profit)
-- ---------------------------------------------------------------------
-- Why: profit should always equal sales - cost. Any mismatch indicates
-- a calculation error upstream and should be recalculated rather than
-- trusted as-is.

SELECT order_line_id, sales, cost, profit, (sales - cost) AS expected_profit
FROM orders
WHERE ROUND(profit, 2) <> ROUND(sales - cost, 2);

-- Remediation: recompute profit directly from sales and cost so the
-- column can never drift out of sync.
--
-- UPDATE orders SET profit = ROUND(sales - cost, 2);

-- ---------------------------------------------------------------------
-- 7. FINAL ROW COUNTS (POST-CLEANING)
-- ---------------------------------------------------------------------

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;
