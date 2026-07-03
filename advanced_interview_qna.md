# 🎯 Advanced SQL Interview Q&A — Tied to This Project

A set of interview-style questions an interviewer might ask about this exact project, with model answers you can use to talk through your work confidently.

---

### Q1. Why did you normalize the data into three tables instead of using one flat table?
**Answer:** The raw brief described one wide table (customer + product + order fields all together). Normalizing into `customers`, `products`, and `orders` removes repeated customer/product attributes from every order row, prevents update anomalies (e.g., a customer's city changing would need to be updated on hundreds of rows in a flat design), and lets me demonstrate JOIN logic meaningfully — which is exactly what interviewers want to see. I still expose a flattened `vw_sales_flat` VIEW for BI tools that expect a single wide table.

### Q2. Why is `order_line_id`, not `order_id`, the primary key of `orders`?
**Answer:** A single checkout (`order_id`) can contain multiple line items — e.g., a customer buying 3 different products in one order. `order_line_id` is the true unique row identifier; `order_id` is a grouping key, not a unique one. This mirrors how real e-commerce systems (Amazon, Flipkart) structure order data.

### Q3. What's the difference between `RANK()`, `DENSE_RANK()`, and `ROW_NUMBER()`, and where did you use each?
**Answer:**
- `ROW_NUMBER()` always assigns a unique, sequential number — no ties (used in Q32 for purchase sequence).
- `RANK()` assigns the same rank to ties but leaves a gap afterward (e.g., 1, 2, 2, 4) — used in Q31/Q35 for revenue leaderboards where ties should be visible.
- `DENSE_RANK()` assigns the same rank to ties with no gap (1, 2, 2, 3) — shown side-by-side with `RANK()` in Q31 specifically to illustrate the difference.

### Q4. Explain the difference between a correlated and non-correlated subquery, with an example from this project.
**Answer:** A non-correlated subquery (Q21) runs once, independently of the outer query — e.g., computing the overall average sales value one time. A correlated subquery (Q22, Q24, Q25) re-executes for every row of the outer query because it references a column from the outer query — e.g., computing each customer's region-relative average spend. Correlated subqueries are more expensive because of the repeated execution, which is why I also show the CTE/window-function alternative (Q30) that achieves similar ranking logic more efficiently.

### Q5. Why use a CTE instead of a subquery in the FROM clause?
**Answer:** CTEs (`WITH ... AS`) are functionally similar to a derived subquery but are far more readable, especially when chaining multiple steps (see Q27, which layers a `category_totals` CTE and a `grand_total` CTE to compute % of revenue). CTEs also let me reuse the same named result set multiple times in the final SELECT without repeating the subquery logic.

### Q6. How would you optimize the query in Q7 (region revenue/profit) if the `orders` table had 50 million rows?
**Answer:** A few levers:
1. Ensure `customer_id` on `orders` and `customer_id` on `customers` are both indexed (the FK already creates this implicitly in most engines) so the JOIN uses an index lookup, not a full scan.
2. If this exact aggregate is queried frequently, consider a pre-aggregated summary table refreshed on a schedule (e.g., nightly), rather than aggregating 50M rows on every dashboard load — this is the same idea behind `vw_monthly_revenue_summary`, just materialized instead of virtual.
3. Partition the `orders` table by `order_date` (range partitioning) if queries are frequently date-filtered, so the engine can prune irrelevant partitions entirely.

### Q7. What's the difference between a `VIEW` and a materialized view, and would you use one here?
**Answer:** A standard `VIEW` (used in Q51/Q52) stores only the query definition — it re-runs the underlying JOIN/aggregation every time it's queried, so it's always up-to-date but adds query cost. A materialized view stores the actual result set physically and must be refreshed on a schedule, trading freshness for speed. For `vw_sales_flat`, a standard view is appropriate since it's a light JOIN. For `vw_monthly_revenue_summary`, if it were queried very frequently by a live dashboard, I'd consider materializing it given aggregation over the full order history.

### Q8. How did you verify your indexes are actually being used?
**Answer:** Using `EXPLAIN` (Q53) on the target query and checking the `key` column of the output — if it names the index (e.g., `idx_orders_order_date`) rather than showing `NULL` with `type: ALL` (a full table scan), the index is being used. I also added a composite index (Q54) after noticing that category-level profit queries filter and join on `product_id` while aggregating `sales`/`profit`, so a composite index covering all three lets the engine potentially satisfy the query from the index alone.

### Q9. Why store `discount` as a decimal fraction (e.g., 0.15) instead of a percentage integer (15)?
**Answer:** Storing it as a fraction means it can be used directly in arithmetic (`unit_price * (1 - discount)`) without a `/100` conversion scattered throughout every query, reducing the chance of an off-by-100 bug. The `CHECK (discount BETWEEN 0 AND 0.80)` constraint also then reads naturally as "0% to 80%".

### Q10. If `profit` can be derived from `sales - cost`, why store it as its own column instead of always calculating it on the fly?
**Answer:** This is a deliberate denormalization trade-off. Storing `profit` avoids recalculating it in every single query (dozens of queries in this project reference `profit` directly), which is simpler to read and slightly faster at query time. The trade-off is a data-integrity risk — the `profit` column could drift out of sync with `sales - cost` if updated incorrectly. I explicitly guard against this in `data_cleaning.sql` with a validation query that flags any row where `profit != sales - cost`.

### Q11. How would you detect and handle outlier orders (e.g., an order 100x larger than typical) before running this analysis?
**Answer:** I'd use a window-function approach: compute each order's z-score or its ratio to the average/median for that product (similar logic to Q25, which already compares each order to its product's average sales), then flag rows beyond a threshold (e.g., 3 standard deviations) for manual review rather than silently excluding them — an unusually large but legitimate bulk order shouldn't be deleted, but it should be understood before being included in trend analysis.

### Q12. This project uses MySQL syntax — what would need to change to run it on PostgreSQL?
**Answer:** The main differences I've noted inline (marked `##` in the SQL files) are: `AUTO_INCREMENT` → `GENERATED ALWAYS AS IDENTITY`, `DATE_FORMAT()` → `TO_CHAR()`, `DATEDIFF(a,b)` → `(a - b)`, `SUBSTRING_INDEX()` → `SPLIT_PART()`, and `DATE_SUB(x, INTERVAL n DAY)` → `x - INTERVAL 'n days'`. The overall JOIN/CTE/window-function logic is standard ANSI SQL and is identical across both engines.

---

## How to Talk About This Project in an Interview

- Lead with the **business problem**, not the SQL syntax: "Leadership needed to understand where revenue and profit were actually coming from, so I built a normalized schema and 50+ analysis queries to answer that."
- Have **one concrete insight memorized cold** — e.g., the Tables sub-category discount/margin finding — and be ready to explain both the query that surfaced it and the recommendation that followed.
- Be ready to justify **schema decisions** (normalization, PK choice, denormalized `profit` column) — these come up more often than the queries themselves in real interviews.
- If asked "what would you do differently at scale," reference the indexing/partitioning/materialized-view answers above.
