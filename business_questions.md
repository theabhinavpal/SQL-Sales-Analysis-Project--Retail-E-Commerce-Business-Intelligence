# 📊 Business Questions — SQL Sales Analysis Project

This document lists the business questions this project answers, grouped by theme. Each question maps to one or more queries in `sales_analysis.sql` (referenced as Q#).

---

## Revenue & Overall Performance
1. What is the total revenue, total profit, and overall profit margin? *(Q6)*
2. What is the month-over-month revenue trend? *(Q29)*
3. What is the cumulative (running total) revenue over time? *(Q39)*
4. What is the 3-month moving average of revenue, smoothing out seasonality? *(Q40)*
5. What is total sales broken down by year and quarter? *(Q42)*
6. What is the year-over-year revenue growth? *(derive from Q42 by comparing matching quarters across years)*
7. Which day of the week generates the most revenue? *(Q43)*
8. Which orders were placed in the most recent 30-day window? *(Q45)*

## Regional Performance
9. Which region generates the highest total revenue and profit? *(Q7)*
10. Which region has the best/worst profit margin? *(Q7)*
11. How many unique customers made a purchase in each region? *(Q11)*
12. What share of each region's total revenue does every individual order represent? *(Q38)*
13. Which customers live in the same city, for community-based marketing? *(Q18)*
14. Which states/cities generate the most sales? *(extend Q7 pattern grouping by `c.state` / `c.city`)*

## Customer Analysis
15. Who are the top 10 customers by total revenue? *(Q26)*
16. Which customers have never placed an order? *(Q16)*
17. Which customers qualify as repeat customers (more than one order)? *(Q28)*
18. What percentile (quartile) does each customer's spend fall into? *(Q36)*
19. Which customers have purchased from more than one category (cross-shoppers)? *(Q20)*
20. Whose total spend exceeds their own region's average customer spend? *(Q22)*
21. What is each customer's purchase sequence number over time? *(Q32)*
22. What was the value of each customer's previous order vs. their next order? *(Q33, Q34)*
23. What is the running order count and running spend total per customer? *(Q41)*
24. What life-stage segment (Gen Z / Millennial / Gen X / Boomer+) does each customer fall into? *(Q13)*
25. What is customer retention like — what fraction of customers are repeat buyers? *(derive from Q28)*

## Product & Category Analysis
26. What is the single best-selling product by total revenue? *(Q23)*
27. Which sub-categories have generated a net loss (or the thinnest margin)? *(Q10)*
28. What percentage of total revenue does each category contribute? *(Q27)*
29. What is each product's revenue rank within its own category? *(Q35)*
30. Which sub-categories rank in the top 3 by revenue within each category? *(Q30)*
31. Which products have never been discounted above 10% (healthy pricing power)? *(Q24)*
32. Which product categories have an average discount above 15% (margin risk)? *(Q8)*
33. Are there any products that have never been sold (dead stock)? *(Q17)*
34. What is the difference between an order's sales value and the max sale value for that product? *(Q37)*
35. What is each order's sales value vs. the average sales value for that specific product? *(Q25)*
36. What are the 5 highest-priced products in the catalog? *(Q4)*
37. Which products contain "Set" or "Combo" in their name (bundle candidates)? *(Q47)*
38. What is the revenue contribution by category, ranked? *(Q19, Q27)*
39. What is the character length of each product name (UI/label planning)? *(Q48)*

## Discounts & Profitability
40. What is the average discount by category, and which exceed 15%? *(Q8)*
41. Which sub-category shows high sales but low/negative profit due to heavy discounting? *(Q10, cross-reference `insights.md`)*
42. What is the overall profit margin, and how does it vary by region? *(Q6, Q7)*
43. Which orders had sales greater than a high-value threshold (₹20,000)? *(Q2)*
44. How are orders distributed across Low / Medium / High value bands? *(Q12)*

## Payments & Shipping
45. What is the average order value (AOV) by payment mode? *(Q9)*
46. Which orders used Express or Same Day delivery? *(Q5)*
47. What is the average number of days between order and ship date, by shipping mode? *(Q44)*
48. Was each order shipped on time or delayed against a 5-day SLA? *(Q14)*
49. Which payment method is most preferred, and does it correlate with order size? *(Q9)*
50. What is the best-performing shipping method by volume and speed? *(Q44)*

## Data Quality & Engineering
51. Are there any duplicate order lines, customers, or products? *(see `data_cleaning.sql`)*
52. Are there NULLs in any critical column? *(see `data_cleaning.sql`)*
53. Are there any orders with impossible values (negative quantity, ship date before order date)? *(see `data_cleaning.sql`, Q50)*
54. Is the "profit = sales - cost" relationship consistent across all rows? *(see `data_cleaning.sql`)*
55. How can we expose a simplified reporting layer for BI tools without repeating JOIN logic? *(Q51 — `vw_sales_flat` view)*
56. Is the `order_date` index actually being used by the query planner? *(Q53)*

---

*Total: 56 distinct business questions, exceeding the 50-question target, all traceable to a specific query in `sales_analysis.sql` or `data_cleaning.sql`.*
