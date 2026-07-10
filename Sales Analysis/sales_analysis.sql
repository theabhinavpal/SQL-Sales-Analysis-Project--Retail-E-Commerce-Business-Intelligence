-- =====================================================================
-- File        : sales_analysis.sql
-- Project      : SQL Sales Analysis Project (Retail E-Commerce)
-- Description  : 54 documented SQL queries answering real business
--                questions, organized by SQL concept. Each query
--                includes: Business Question, Explanation, Expected
--                Output, and Business Insight as inline comments.
-- Dialect      : Written for MySQL 8.0. Postgres-specific notes (##)
--                are added wherever syntax differs materially.
-- =====================================================================

USE sql_sales_analysis;

-- #######################################################################
-- SECTION A: BASIC SELECT / WHERE / ORDER BY / LIMIT
-- #######################################################################

-- Q1 --------------------------------------------------------------------
-- Business Question : What do the first 10 orders in the dataset look like?
-- Explanation        : A basic SELECT with ORDER BY + LIMIT to preview
--                       the earliest transactions chronologically.
-- Expected Output     : 10 rows, earliest order_date first.
-- Business Insight    : Useful as a first sanity check when onboarding
--                       onto a new dataset before deeper analysis.
SELECT order_id, order_date, customer_id, product_id, sales
FROM orders
ORDER BY order_date ASC
LIMIT 10;

-- Q2 --------------------------------------------------------------------
-- Business Question : Which orders had sales greater than 20,000?
-- Explanation        : Simple WHERE filter on a numeric threshold.
-- Expected Output     : All high-value order lines, sorted descending.
-- Business Insight    : High-value orders often justify manual QA or
--                       priority customer-service handling.
SELECT order_id, product_id, sales
FROM orders
WHERE sales > 20000
ORDER BY sales DESC;

-- Q3 --------------------------------------------------------------------
-- Business Question : Which customers are based in Maharashtra or Gujarat?
-- Explanation        : WHERE ... IN() filters on multiple state values.
-- Expected Output     : Customer rows limited to the two specified states.
-- Business Insight    : Supports state-level targeted marketing campaigns.
SELECT customer_id, customer_name, city, state
FROM customers
WHERE state IN ('Maharashtra', 'Gujarat')
ORDER BY state, city;

-- Q4 --------------------------------------------------------------------
-- Business Question : What are the 5 highest-priced products in the catalog?
-- Explanation        : ORDER BY DESC + LIMIT to find top-N by price.
-- Expected Output     : 5 rows sorted by unit_price descending.
-- Business Insight    : Identifies premium/flagship products that may
--                       warrant featured placement or premium marketing.
SELECT product_name, category, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 5;

-- Q5 --------------------------------------------------------------------
-- Business Question : Which orders were shipped using Express or Same Day delivery?
-- Explanation        : Multi-condition WHERE combined with ORDER BY.
-- Expected Output     : Order lines using faster shipping options only.
-- Business Insight    : Helps quantify demand for premium shipping,
--                       informing logistics capacity planning.
SELECT order_id, shipping_mode, order_date, sales
FROM orders
WHERE shipping_mode IN ('Express', 'Same Day')
ORDER BY order_date DESC
LIMIT 20;


-- #######################################################################
-- SECTION B: AGGREGATE FUNCTIONS / GROUP BY / HAVING
-- #######################################################################

-- Q6 --------------------------------------------------------------------
-- Business Question : What is the total revenue, total profit, and overall profit margin?
-- Explanation        : SUM() aggregates across the full orders table;
--                       margin is derived as profit / sales.
-- Expected Output     : A single summary row.
-- Business Insight    : The single most important headline KPI for
--                       leadership reporting.
SELECT
    ROUND(SUM(sales), 2)  AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS overall_margin_pct
FROM orders;

-- Q7 --------------------------------------------------------------------
-- Business Question : Which region generates the highest total revenue and profit?
-- Explanation        : JOIN to customers to bring in region, then
--                       GROUP BY region with SUM aggregates.
-- Expected Output     : 5 rows (one per region), sorted by revenue desc.
-- Business Insight    : Directs regional budget allocation and
--                       identifies which regions to double down on.
SELECT
    c.region,
    ROUND(SUM(o.sales), 2)  AS total_revenue,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2) AS margin_pct
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY total_revenue DESC;

-- Q8 --------------------------------------------------------------------
-- Business Question : Which product categories have an average discount above 15%?
-- Explanation        : GROUP BY category with AVG(), filtered post-
--                       aggregation using HAVING (WHERE cannot filter
--                       on an aggregate result).
-- Expected Output     : Only categories whose average discount exceeds 15%.
-- Business Insight    : Flags categories at risk of margin erosion from
--                       over-discounting.
SELECT
    p.category,
    ROUND(AVG(o.discount) * 100, 2) AS avg_discount_pct
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
HAVING AVG(o.discount) > 0.15
ORDER BY avg_discount_pct DESC;

-- Q9 --------------------------------------------------------------------
-- Business Question : What is the average order value (AOV) per payment mode?
-- Explanation        : AVG() grouped by payment_mode.
-- Expected Output     : 6 rows, one per payment method.
-- Business Insight    : Payment methods with a higher AOV may warrant
--                       promotional emphasis at checkout.
SELECT
    payment_mode,
    COUNT(*) AS num_orders,
    ROUND(AVG(sales), 2) AS avg_order_value
FROM orders
GROUP BY payment_mode
ORDER BY avg_order_value DESC;

-- Q10 -------------------------------------------------------------------
-- Business Question : Which sub-categories have generated a net loss overall?
-- Explanation        : GROUP BY sub_category, HAVING total profit < 0.
-- Expected Output     : Any sub-category whose SUM(profit) is negative.
-- Business Insight    : Immediate red flag for pricing/discount policy
--                       review on these specific product lines.
SELECT
    p.sub_category,
    ROUND(SUM(o.sales), 2)  AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.sub_category
HAVING SUM(o.profit) < 0
ORDER BY total_profit ASC;

-- Q11 -------------------------------------------------------------------
-- Business Question : How many unique customers made a purchase in each region?
-- Explanation        : COUNT(DISTINCT ...) grouped by region.
-- Expected Output     : 5 rows showing distinct customer counts.
-- Business Insight    : Distinguishes revenue driven by many customers
--                       vs. a few big spenders, per region.
SELECT
    c.region,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    COUNT(*) AS total_order_lines
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY unique_customers DESC;


-- #######################################################################
-- SECTION C: CASE WHEN
-- #######################################################################

-- Q12 -------------------------------------------------------------------
-- Business Question : How many orders fall into Low / Medium / High value bands?
-- Explanation        : CASE WHEN buckets each order by its sales amount.
-- Expected Output     : 3 rows, one per band, with counts and revenue.
-- Business Insight    : Simple segmentation for targeted follow-up
--                       campaigns (e.g. upsell "Medium" band customers).
SELECT
    CASE
        WHEN sales < 2000 THEN 'Low Value'
        WHEN sales BETWEEN 2000 AND 10000 THEN 'Medium Value'
        ELSE 'High Value'
    END AS order_value_band,
    COUNT(*) AS num_orders,
    ROUND(SUM(sales), 2) AS total_revenue
FROM orders
GROUP BY order_value_band
ORDER BY total_revenue DESC;

-- Q13 -------------------------------------------------------------------
-- Business Question : What life-stage segment does each customer fall into by age?
-- Explanation        : CASE WHEN applied at the row level (no aggregation).
-- Expected Output     : Every customer tagged with an age segment.
-- Business Insight    : Enables age-based marketing personalization.
SELECT
    customer_id,
    customer_name,
    age,
    CASE
        WHEN age < 25 THEN 'Gen Z'
        WHEN age BETWEEN 25 AND 40 THEN 'Millennial'
        WHEN age BETWEEN 41 AND 55 THEN 'Gen X'
        ELSE 'Boomer+'
    END AS age_segment
FROM customers
ORDER BY age;

-- Q14 -------------------------------------------------------------------
-- Business Question : Was each order shipped on time, or delayed (>5 days)?
-- Explanation        : CASE WHEN compares the gap between order_date
--                       and ship_date against a business SLA of 5 days.
-- Expected Output     : Every order tagged "On Time" or "Delayed".
-- Business Insight    : Feeds directly into logistics SLA reporting.
SELECT
    order_id,
    order_date,
    ship_date,
    DATEDIFF(ship_date, order_date) AS days_to_ship,   -- ## Postgres: (ship_date - order_date)
    CASE
        WHEN DATEDIFF(ship_date, order_date) <= 5 THEN 'On Time'
        ELSE 'Delayed'
    END AS shipping_status
FROM orders
ORDER BY days_to_ship DESC
LIMIT 20;


-- #######################################################################
-- SECTION D: JOINS
-- #######################################################################

-- Q15 -------------------------------------------------------------------
-- Business Question : What is the full transaction detail (customer + product + order)?
-- Explanation        : INNER JOIN across all three tables to reconstruct
--                       the flat "one row per transaction" view.
-- Expected Output     : One row per order line with full context.
-- Business Insight    : This is the base view most BI dashboards
--                       (Power BI/Tableau) would connect to.
SELECT
    o.order_id, o.order_date, c.customer_name, c.region,
    p.product_name, p.category, o.quantity, o.sales, o.profit
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN products p ON o.product_id = p.product_id
ORDER BY o.order_date DESC
LIMIT 20;

-- Q16 -------------------------------------------------------------------
-- Business Question : Are there any customers who have never placed an order?
-- Explanation        : LEFT JOIN from customers to orders; unmatched
--                       rows (never ordered) will have NULL order_id.
-- Expected Output     : Customers with zero purchase history, if any.
-- Business Insight    : Identifies a re-engagement / win-back target
--                       list for marketing.
SELECT c.customer_id, c.customer_name, c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_line_id IS NULL;

-- Q17 -------------------------------------------------------------------
-- Business Question : Are there any products that have never been sold?
-- Explanation        : RIGHT JOIN from orders to products (equivalent
--                       to a LEFT JOIN with tables swapped) — included
--                       here to explicitly demonstrate RIGHT JOIN syntax.
-- Expected Output     : Products with zero associated order lines, if any.
-- Business Insight    : Flags dead stock/catalog items to potentially
--                       discontinue or promote.
SELECT p.product_id, p.product_name, p.category
FROM orders o
RIGHT JOIN products p ON o.product_id = p.product_id
WHERE o.order_line_id IS NULL;

-- Q18 -------------------------------------------------------------------
-- Business Question : Which pairs of customers live in the same city (for
--                       potential regional/community marketing)?
-- Explanation        : SELF JOIN on the customers table, matching rows
--                       to other rows sharing the same city while
--                       excluding a row matching itself.
-- Expected Output     : Pairs of distinct customers who share a city.
-- Business Insight    : Supports city-level referral or community
--                       marketing programs.
SELECT
    c1.customer_name AS customer_a,
    c2.customer_name AS customer_b,
    c1.city
FROM customers c1
INNER JOIN customers c2
    ON c1.city = c2.city
   AND c1.customer_id < c2.customer_id
ORDER BY c1.city
LIMIT 20;

-- Q19 -------------------------------------------------------------------
-- Business Question : What is total revenue per category, including
--                       categories with zero sales (if any existed)?
-- Explanation        : LEFT JOIN from products to orders ensures every
--                       category appears even with no matching sales.
-- Expected Output     : One row per category; SUM defaults to 0 via
--                       COALESCE if there were no matching orders.
-- Business Insight    : Full catalog-coverage reporting, avoiding
--                       silent omission of underperforming categories.
SELECT
    p.category,
    COALESCE(SUM(o.sales), 0) AS total_sales
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- Q20 -------------------------------------------------------------------
-- Business Question : Which customers have purchased from more than one category?
-- Explanation        : JOIN + GROUP BY + HAVING COUNT(DISTINCT category) > 1.
-- Expected Output     : Customers who cross-shop multiple categories.
-- Business Insight    : Cross-category buyers tend to have higher
--                       lifetime value — good cross-sell targets.
SELECT
    c.customer_id, c.customer_name,
    COUNT(DISTINCT p.category) AS categories_purchased
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY categories_purchased DESC
LIMIT 20;


-- #######################################################################
-- SECTION E: SUBQUERIES & CORRELATED SUBQUERIES
-- #######################################################################

-- Q21 -------------------------------------------------------------------
-- Business Question : Which orders had a sales value above the overall average?
-- Explanation        : A non-correlated subquery computes the global
--                       average once, and the outer query filters against it.
-- Expected Output     : All order lines exceeding the average sale value.
-- Business Insight    : Isolates the "above-average" transaction segment
--                       for closer profiling.
SELECT order_id, product_id, sales
FROM orders
WHERE sales > (SELECT AVG(sales) FROM orders)
ORDER BY sales DESC
LIMIT 20;

-- Q22 -------------------------------------------------------------------
-- Business Question : Who are the customers whose total spend exceeds
--                       their region's average customer spend?
-- Explanation        : Correlated subquery — the inner query re-evaluates
--                       per outer row, referencing the outer customer's region.
-- Expected Output     : Above-average spenders within their own region.
-- Business Insight    : A relative (region-aware) high-value customer
--                       list — more precise than a single global threshold.
SELECT
    c.customer_id, c.customer_name, c.region,
    (SELECT ROUND(SUM(o2.sales), 2) FROM orders o2 WHERE o2.customer_id = c.customer_id) AS customer_total_spend
FROM customers c
WHERE (
    SELECT SUM(o.sales) FROM orders o WHERE o.customer_id = c.customer_id
) > (
    SELECT AVG(region_totals.total_spend)
    FROM (
        SELECT o3.customer_id, SUM(o3.sales) AS total_spend
        FROM orders o3
        INNER JOIN customers c3 ON o3.customer_id = c3.customer_id
        WHERE c3.region = c.region
        GROUP BY o3.customer_id
    ) region_totals
)
ORDER BY customer_total_spend DESC
LIMIT 20;

-- Q23 -------------------------------------------------------------------
-- Business Question : What is the single best-selling product by total revenue?
-- Explanation        : Subquery in the FROM clause aggregates first,
--                       outer query picks the top row.
-- Expected Output     : One row — the top product and its revenue.
-- Business Insight    : The "hero SKU" — a strong candidate for
--                       featured homepage placement.
SELECT product_name, total_sales
FROM (
    SELECT p.product_name, SUM(o.sales) AS total_sales
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.product_name
) AS product_totals
ORDER BY total_sales DESC
LIMIT 1;

-- Q24 -------------------------------------------------------------------
-- Business Question : Which products have never been discounted above 10%?
-- Explanation        : NOT EXISTS correlated subquery checks that no
--                       matching order line for that product exceeds
--                       the discount threshold.
-- Expected Output     : Products that have always sold at a modest
--                       discount level.
-- Business Insight    : These products maintain healthy pricing power
--                       and don't rely on deep discounts to sell.
SELECT p.product_id, p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.product_id = p.product_id
      AND o.discount > 0.10
);

-- Q25 -------------------------------------------------------------------
-- Business Question : What is each order's sales value compared to the
--                       average sales value for that specific product?
-- Explanation        : Correlated subquery computes a per-product
--                       average that's re-evaluated for every outer row.
-- Expected Output     : Every order line with its product's average
--                       sales value alongside it for comparison.
-- Business Insight    : Flags unusually large or small transactions
--                       relative to a product's typical sale size.
SELECT
    o.order_id, o.product_id, o.sales,
    (SELECT ROUND(AVG(o2.sales), 2) FROM orders o2 WHERE o2.product_id = o.product_id) AS product_avg_sales
FROM orders o
ORDER BY o.sales DESC
LIMIT 20;


-- #######################################################################
-- SECTION F: COMMON TABLE EXPRESSIONS (CTEs)
-- #######################################################################

-- Q26 -------------------------------------------------------------------
-- Business Question : What are the top 10 customers by total revenue?
-- Explanation        : A CTE pre-aggregates spend per customer, keeping
--                       the final SELECT simple and readable.
-- Expected Output     : Top 10 customers ranked by total spend.
-- Business Insight    : This is the VIP list — prime targets for loyalty
--                       programs and personalized outreach.
WITH customer_totals AS (
    SELECT
        c.customer_id, c.customer_name, c.region,
        SUM(o.sales) AS total_spend
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name, c.region
)
SELECT customer_id, customer_name, region, ROUND(total_spend, 2) AS total_spend
FROM customer_totals
ORDER BY total_spend DESC
LIMIT 10;

-- Q27 -------------------------------------------------------------------
-- Business Question : What percentage of total company revenue does each
--                       category contribute?
-- Explanation        : CTE computes category totals; outer query divides
--                       by the grand total (via a second CTE / scalar).
-- Expected Output     : Each category with its % revenue contribution.
-- Business Insight    : Shows category concentration risk — over-reliance
--                       on one category is a business vulnerability.
WITH category_totals AS (
    SELECT p.category, SUM(o.sales) AS category_sales
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category
),
grand_total AS (
    SELECT SUM(category_sales) AS total_sales FROM category_totals
)
SELECT
    ct.category,
    ROUND(ct.category_sales, 2) AS category_sales,
    ROUND(ct.category_sales / gt.total_sales * 100, 2) AS pct_of_total_revenue
FROM category_totals ct
CROSS JOIN grand_total gt
ORDER BY pct_of_total_revenue DESC;

-- Q28 -------------------------------------------------------------------
-- Business Question : Which customers qualify as "repeat customers"
--                       (placed more than one distinct order)?
-- Explanation        : CTE counts distinct order_ids per customer; the
--                       outer query filters to those with more than one.
-- Expected Output     : Customer list with their distinct order count.
-- Business Insight    : Repeat purchase rate is a core retention KPI.
WITH order_counts AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS distinct_orders
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, oc.distinct_orders
FROM order_counts oc
INNER JOIN customers c ON oc.customer_id = c.customer_id
WHERE oc.distinct_orders > 1
ORDER BY oc.distinct_orders DESC
LIMIT 20;

-- Q29 -------------------------------------------------------------------
-- Business Question : What is the month-over-month revenue trend?
-- Explanation        : CTE buckets sales by calendar month; outer
--                       query simply orders the result chronologically.
-- Expected Output     : One row per month with total revenue.
-- Business Insight    : Foundation for seasonal planning and revenue
--                       forecasting.
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,   -- ## Postgres: TO_CHAR(order_date, 'YYYY-MM')
        SUM(sales) AS monthly_revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT sales_month, ROUND(monthly_revenue, 2) AS monthly_revenue
FROM monthly_sales
ORDER BY sales_month;

-- Q30 -------------------------------------------------------------------
-- Business Question : Which sub-categories rank in the top 3 by revenue
--                       within each category?
-- Explanation        : CTE computes sub-category totals + a window
--                       RANK(); outer query filters to rank <= 3.
--                       (Demonstrates CTE + window function combined.)
-- Expected Output     : Top 3 sub-categories per category.
-- Business Insight    : Highlights each category's "hero" sub-categories
--                       worth prioritizing in inventory planning.
WITH sub_category_sales AS (
    SELECT
        p.category, p.sub_category,
        SUM(o.sales) AS total_sales,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.sales) DESC) AS category_rank
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.sub_category
)
SELECT category, sub_category, ROUND(total_sales, 2) AS total_sales, category_rank
FROM sub_category_sales
WHERE category_rank <= 3
ORDER BY category, category_rank;


-- #######################################################################
-- SECTION G: WINDOW FUNCTIONS
-- #######################################################################

-- Q31 -------------------------------------------------------------------
-- Business Question : What is the revenue rank of every region (with ties
--                       sharing the same rank, no gaps)?
-- Explanation        : RANK() vs DENSE_RANK() shown side by side to
--                       illustrate the difference in tie handling.
-- Expected Output     : 5 rows, ranked by revenue descending.
-- Business Insight    : Simple leaderboard-style reporting for
--                       leadership dashboards.
SELECT
    c.region,
    ROUND(SUM(o.sales), 2) AS total_sales,
    RANK()       OVER (ORDER BY SUM(o.sales) DESC) AS rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY SUM(o.sales) DESC) AS rank_no_gaps
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region;

-- Q32 -------------------------------------------------------------------
-- Business Question : What is each customer's purchase sequence number
--                       (1st order, 2nd order, 3rd order...)?
-- Explanation        : ROW_NUMBER() partitioned by customer, ordered by
--                       order_date, assigns a unique sequential number.
-- Expected Output     : Every order line tagged with its sequence
--                       number within that customer's history.
-- Business Insight    : Enables "first purchase" vs "repeat purchase"
--                       cohort analysis.
SELECT
    customer_id, order_id, order_date, sales,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS purchase_sequence
FROM orders
ORDER BY customer_id, purchase_sequence
LIMIT 20;

-- Q33 -------------------------------------------------------------------
-- Business Question : What was the sales value of each customer's
--                       previous order (for period-over-period comparison)?
-- Explanation        : LAG() looks back one row within each customer's
--                       partition, ordered by date.
-- Expected Output     : Every order line with the prior order's sales
--                       value alongside it.
-- Business Insight    : Enables detection of customers whose order size
--                       is shrinking (churn risk signal).
SELECT
    customer_id, order_date, sales,
    LAG(sales, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_sales
FROM orders
ORDER BY customer_id, order_date
LIMIT 20;

-- Q34 -------------------------------------------------------------------
-- Business Question : What is the sales value of each customer's NEXT order?
-- Explanation        : LEAD() is the mirror image of LAG(), looking
--                       forward within the partition.
-- Expected Output     : Every order line with the following order's
--                       sales value alongside it.
-- Business Insight    : Useful for building "time until next purchase"
--                       retention features.
SELECT
    customer_id, order_date, sales,
    LEAD(sales, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_sales
FROM orders
ORDER BY customer_id, order_date
LIMIT 20;

-- Q35 -------------------------------------------------------------------
-- Business Question : What is each product's revenue rank within its
--                       own category?
-- Explanation        : RANK() with PARTITION BY category resets the
--                       ranking counter for every category.
-- Expected Output     : Every product with a rank scoped to its category.
-- Business Insight    : Identifies the top performer(s) in every
--                       category, not just globally.
SELECT
    p.category, p.product_name,
    ROUND(SUM(o.sales), 2) AS total_sales,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.sales) DESC) AS rank_in_category
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, p.product_name
ORDER BY p.category, rank_in_category
LIMIT 30;

-- Q36 -------------------------------------------------------------------
-- Business Question : What percentile does each customer's total spend
--                       fall into (quartiles)?
-- Explanation        : NTILE(4) splits customers into four equal-sized
--                       buckets ordered by spend — quartile segmentation.
-- Expected Output     : Every customer tagged 1 (lowest) to 4 (highest).
-- Business Insight    : Quartile 4 is the VIP segment; Quartile 1 is a
--                       re-engagement target.
SELECT
    c.customer_id, c.customer_name,
    ROUND(SUM(o.sales), 2) AS total_spend,
    NTILE(4) OVER (ORDER BY SUM(o.sales)) AS spend_quartile
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC
LIMIT 20;

-- Q37 -------------------------------------------------------------------
-- Business Question : What is the difference between each order's sales
--                       value and the maximum sales value for that product?
-- Explanation        : A window aggregate (MAX() OVER PARTITION) without
--                       collapsing rows, unlike a normal GROUP BY.
-- Expected Output     : Every order line alongside its product's max
--                       sale value and the gap between them.
-- Business Insight    : Useful for spotting under-performing individual
--                       transactions relative to a product's ceiling.
SELECT
    order_id, product_id, sales,
    MAX(sales) OVER (PARTITION BY product_id) AS product_max_sales,
    ROUND(MAX(sales) OVER (PARTITION BY product_id) - sales, 2) AS gap_from_max
FROM orders
ORDER BY gap_from_max DESC
LIMIT 20;

-- Q38 -------------------------------------------------------------------
-- Business Question : What share of each region's total revenue does
--                       every individual order represent?
-- Explanation        : Window SUM() as the denominator lets us compute
--                       a percent-of-partition-total per row.
-- Expected Output     : Every order with its % contribution to its
--                       region's total revenue.
-- Business Insight    : Flags single orders that make up an outsized
--                       share of a region's revenue (concentration risk).
SELECT
    o.order_id, c.region, o.sales,
    ROUND(o.sales / SUM(o.sales) OVER (PARTITION BY c.region) * 100, 4) AS pct_of_region_revenue
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY pct_of_region_revenue DESC
LIMIT 20;


-- #######################################################################
-- SECTION H: RUNNING TOTALS & MOVING AVERAGES
-- #######################################################################

-- Q39 -------------------------------------------------------------------
-- Business Question : What is the cumulative (running total) revenue
--                       over time?
-- Explanation        : SUM() OVER (ORDER BY ... ROWS UNBOUNDED PRECEDING)
--                       accumulates revenue chronologically.
-- Expected Output     : One row per month with a running cumulative total.
-- Business Insight    : Tracks progress toward annual/quarterly revenue
--                       targets at a glance.
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(sales) AS monthly_revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY sales_month
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total_revenue
FROM monthly_sales
ORDER BY sales_month;

-- Q40 -------------------------------------------------------------------
-- Business Question : What is the 3-month moving average of revenue?
-- Explanation        : SUM()/AVG() OVER a bounded window frame of the
--                       current row plus the two preceding rows.
-- Expected Output     : One row per month with a smoothed 3-month average.
-- Business Insight    : Smooths out monthly noise/seasonality to reveal
--                       the underlying growth trend.
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(sales) AS monthly_revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (ORDER BY sales_month
          ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3month
FROM monthly_sales
ORDER BY sales_month;

-- Q41 -------------------------------------------------------------------
-- Business Question : What is the running count and running total of
--                       orders placed by each customer over time?
-- Explanation        : Two window functions (COUNT, SUM) partitioned by
--                       customer, both accumulating chronologically.
-- Expected Output     : Every order line with a per-customer running
--                       order count and running spend total.
-- Business Insight    : Powers a customer lifetime-value-over-time curve.
SELECT
    customer_id, order_date, sales,
    COUNT(*) OVER (PARTITION BY customer_id ORDER BY order_date
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_order_count,
    ROUND(SUM(sales) OVER (PARTITION BY customer_id ORDER BY order_date
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_customer_spend
FROM orders
ORDER BY customer_id, order_date
LIMIT 20;


-- #######################################################################
-- SECTION I: DATE FUNCTIONS
-- #######################################################################

-- Q42 -------------------------------------------------------------------
-- Business Question : What are total sales broken down by year and quarter?
-- Explanation        : YEAR() and QUARTER() extract date parts for
--                       grouping.
-- Expected Output     : One row per year-quarter combination.
-- Business Insight    : Standard format for quarterly business reviews (QBRs).
SELECT
    YEAR(order_date) AS sales_year,
    QUARTER(order_date) AS sales_quarter,          -- ## Postgres: EXTRACT(QUARTER FROM order_date)
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY sales_year, sales_quarter;

-- Q43 -------------------------------------------------------------------
-- Business Question : Which day of the week generates the most revenue?
-- Explanation        : DAYNAME() extracts the weekday name for grouping.
-- Expected Output     : 7 rows, one per weekday, ranked by revenue.
-- Business Insight    : Informs weekday-specific promotions and staffing
--                       for customer support/fulfillment.
SELECT
    DAYNAME(order_date) AS day_of_week,             -- ## Postgres: TO_CHAR(order_date, 'Day')
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*) AS num_orders
FROM orders
GROUP BY DAYNAME(order_date)
ORDER BY total_sales DESC;

-- Q44 -------------------------------------------------------------------
-- Business Question : What is the average number of days between order
--                       date and ship date, by shipping mode?
-- Explanation        : DATEDIFF() calculates the day gap per row; AVG()
--                       aggregates it by shipping_mode.
-- Expected Output     : 4 rows (one per shipping mode) with average
--                       fulfillment time.
-- Business Insight    : Validates whether "Express"/"Same Day" labels
--                       are actually being honored operationally.
SELECT
    shipping_mode,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS avg_days_to_ship
FROM orders
GROUP BY shipping_mode
ORDER BY avg_days_to_ship;

-- Q45 -------------------------------------------------------------------
-- Business Question : Which orders were placed in the most recent 30 days
--                       of available data?
-- Explanation        : DATE_SUB() combined with a subquery for MAX(order_date)
--                       makes this reusable regardless of "today's" date.
-- Expected Output     : Orders from the final 30-day window of the dataset.
-- Business Insight    : Approximates a "last 30 days" operational report,
--                       independent of when the query is actually run.
SELECT order_id, order_date, sales
FROM orders
WHERE order_date >= DATE_SUB((SELECT MAX(order_date) FROM orders), INTERVAL 30 DAY)  -- ## Postgres: (SELECT MAX(order_date) FROM orders) - INTERVAL '30 days'
ORDER BY order_date DESC;


-- #######################################################################
-- SECTION J: STRING FUNCTIONS
-- #######################################################################

-- Q46 -------------------------------------------------------------------
-- Business Question : What are customers' first names only (for
--                       personalized email greetings)?
-- Explanation        : SUBSTRING_INDEX() splits the full name on the
--                       first space to isolate the first name.
-- Expected Output     : customer_id + extracted first name.
-- Business Insight    : Direct input for "Hi {first_name}," email
--                       personalization tokens.
SELECT
    customer_id,
    customer_name,
    SUBSTRING_INDEX(customer_name, ' ', 1) AS first_name   -- ## Postgres: SPLIT_PART(customer_name, ' ', 1)
FROM customers
LIMIT 10;

-- Q47 -------------------------------------------------------------------
-- Business Question : Which products have "Set" or "Combo" in their name
--                       (potential bundle-deal candidates)?
-- Explanation        : LIKE with wildcards performs a pattern match on
--                       the product name.
-- Expected Output     : Products whose name contains those keywords.
-- Business Insight    : Identifies existing bundle-style SKUs to analyze
--                       for bundle-pricing effectiveness.
SELECT product_id, product_name, category
FROM products
WHERE product_name LIKE '%Set%' OR product_name LIKE '%Combo%';

-- Q48 -------------------------------------------------------------------
-- Business Question : What is the character length of each product name
--                       (useful for UI/label truncation planning)?
-- Explanation        : LENGTH()/CONCAT() combined for a simple derived
--                       string metric.
-- Expected Output     : Product names with their character count.
-- Business Insight    : Flags overly long product names that may break
--                       card layouts on the storefront UI.
SELECT
    product_name,
    LENGTH(product_name) AS name_length,
    CONCAT(UPPER(LEFT(product_name, 1)), LOWER(SUBSTRING(product_name, 2))) AS normalized_case_example
FROM products
ORDER BY name_length DESC
LIMIT 10;


-- #######################################################################
-- SECTION K: NULL HANDLING
-- #######################################################################

-- Q49 -------------------------------------------------------------------
-- Business Question : If a discount was somehow missing, what would the
--                       effective discount default to for reporting purposes?
-- Explanation        : COALESCE() supplies a fallback value if a NULL is
--                       encountered, preventing NULL from silently
--                       propagating into downstream calculations.
-- Expected Output     : Every order with a guaranteed non-NULL discount value.
-- Business Insight    : Defensive coding practice — reports should never
--                       silently drop rows or show blank values due to NULLs.
SELECT
    order_id,
    COALESCE(discount, 0.00) AS safe_discount
FROM orders
LIMIT 10;

-- Q50 -------------------------------------------------------------------
-- Business Question : Are there any orders missing a customer or product
--                       reference (broken foreign keys from a source
--                       system before constraints were enforced)?
-- Explanation        : IS NULL checks directly on the foreign key columns.
-- Expected Output     : Any orphaned order rows (expected to be empty here
--                       since foreign keys are enforced in this schema).
-- Business Insight    : A standard data-integrity audit query to run
--                       before trusting any downstream report.
SELECT order_line_id, order_id, customer_id, product_id
FROM orders
WHERE customer_id IS NULL OR product_id IS NULL;


-- #######################################################################
-- SECTION L: VIEWS
-- #######################################################################

-- Q51 -------------------------------------------------------------------
-- Business Question : How can we give BI tools (Power BI/Tableau) a
--                       single, simple table to connect to instead of
--                       three normalized tables?
-- Explanation        : A VIEW encapsulates the 3-way JOIN so downstream
--                       tools/analysts never have to rewrite it.
-- Expected Output     : A reusable "flat" reporting view.
-- Business Insight    : Standard practice — protects BI consumers from
--                       schema complexity and JOIN mistakes.
CREATE OR REPLACE VIEW vw_sales_flat AS
SELECT
    o.order_line_id, o.order_id, o.order_date, o.ship_date,
    c.customer_id, c.customer_name, c.gender, c.age, c.city, c.state, c.region,
    p.product_id, p.product_name, p.category, p.sub_category,
    o.quantity, o.unit_price, o.discount, o.sales, o.cost, o.profit,
    o.payment_mode, o.shipping_mode
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN products p ON o.product_id = p.product_id;

-- Example usage of the view:
SELECT region, category, ROUND(SUM(sales), 2) AS total_sales
FROM vw_sales_flat
GROUP BY region, category
ORDER BY total_sales DESC
LIMIT 10;

-- Q52 -------------------------------------------------------------------
-- Business Question : How can we expose a pre-aggregated monthly revenue
--                       summary for a lightweight executive dashboard?
-- Explanation        : A second VIEW pre-computes the monthly aggregate
--                       so a dashboard tool can query it directly
--                       without re-running the full aggregation each time.
-- Expected Output     : A reusable monthly summary view.
-- Business Insight    : Reduces load on the transactional tables for
--                       frequently-refreshed dashboard widgets.
CREATE OR REPLACE VIEW vw_monthly_revenue_summary AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(sales), 2)  AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

SELECT * FROM vw_monthly_revenue_summary ORDER BY sales_month;


-- #######################################################################
-- SECTION M: INDEXES & PERFORMANCE OPTIMIZATION
-- #######################################################################

-- Q53 -------------------------------------------------------------------
-- Business Question : Is our most common query (revenue by date range)
--                       running efficiently?
-- Explanation        : EXPLAIN shows the query execution plan — whether
--                       MySQL uses the idx_orders_order_date index
--                       (defined in database_schema.sql) instead of a
--                       full table scan.
-- Expected Output     : An execution plan showing "type: range" or
--                       similar, referencing idx_orders_order_date under
--                       the "key" column, rather than "ALL" (full scan).
-- Business Insight    : Confirms the index investment is actually being
--                       used by the query planner, not just present.
EXPLAIN
SELECT SUM(sales) FROM orders
WHERE order_date BETWEEN '2023-10-01' AND '2023-12-31';

-- Q54 -------------------------------------------------------------------
-- Business Question : What additional index would speed up frequent
--                       "profit by category" reporting queries?
-- Explanation        : A composite index on the join + filter columns
--                       used together lets the optimizer avoid touching
--                       unrelated columns/rows.
-- Expected Output     : A new index that subsequent EXPLAIN calls on
--                       category-based profit queries can leverage.
-- Business Insight    : Proactive indexing based on observed query
--                       patterns is a core performance-tuning skill for
--                       analysts working with large transactional tables.
CREATE INDEX idx_orders_product_sales_profit ON orders(product_id, sales, profit);

EXPLAIN
SELECT p.category, SUM(o.profit)
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.category;

-- =====================================================================
-- END OF sales_analysis.sql — 54 queries total
-- =====================================================================
