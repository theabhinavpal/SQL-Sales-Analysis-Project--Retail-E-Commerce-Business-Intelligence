# 🛒 SQL Sales Analysis Project — Retail E-Commerce Business Intelligence

![SQL](https://img.shields.io/badge/SQL-MySQL%2FPostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Level](https://img.shields.io/badge/Level-Entry--Level%20Data%20Analyst-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 📌 Project Overview

This project simulates the role of a **Data Analyst at a mid-sized retail e-commerce company**. Using a realistic sales dataset of 5,000+ transactions, I designed a normalized relational database, performed end-to-end data cleaning, and wrote 50+ SQL queries — ranging from basic aggregations to advanced window functions and CTEs — to answer real business questions around revenue, profitability, customer behavior, and regional performance.

The goal of this project is to demonstrate **production-level SQL skills** that are directly applicable to Data Analyst roles: schema design, data cleaning, exploratory analysis, and translating query results into actionable business insights.

---

## ❓ Business Problem

The leadership team at a growing retail e-commerce company needs a clear, data-backed understanding of:

- Where revenue and profit are coming from (region, category, product)
- Which customers drive the most value, and whether they return
- How discounts are affecting profit margins
- Which shipping and payment methods are most efficient and preferred
- How sales trend across months and seasons

This project answers those questions directly from raw transactional data using SQL — the same way an analyst would in a real BI/reporting workflow before dashboards are ever built.

---

## 🗂️ Dataset Description

A synthetic but realistic retail sales dataset containing **5,000+ order-level records**, modeled after real e-commerce transaction logs.

| Column | Description |
|---|---|
| Order_ID | Unique identifier for each order |
| Order_Date / Ship_Date | Order placement and shipping dates |
| Customer_ID / Customer_Name | Customer identifiers |
| Gender / Age | Customer demographics |
| City / State / Region | Customer location |
| Product_ID / Product_Name | Product identifiers |
| Category / Sub_Category | Product classification |
| Quantity / Unit_Price / Discount | Order line details |
| Sales / Cost / Profit | Financial metrics |
| Payment_Mode | Payment method used |
| Shipping_Mode | Shipping method used |

The dataset intentionally includes real-world messiness (duplicates, NULLs, inconsistent text casing/categories) which is cleaned in `data_cleaning.sql` before analysis.

---

## 🛠️ Tools Used

- **SQL** (MySQL 8.0 / PostgreSQL compatible syntax, noted where they differ)
- **DB Design:** Normalized relational schema (3NF-oriented, with intentional denormalization documented)
- **Version Control:** Git & GitHub
- *(Optional extension: Power BI / Tableau for visualization — see Future Improvements)*

---

## 🧠 SQL Concepts Demonstrated

- Database & table design (PK/FK, constraints, indexes)
- Data cleaning (duplicates, NULLs, standardization)
- `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`
- Aggregate functions, `GROUP BY`, `HAVING`
- `CASE WHEN` logic
- `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `SELF JOIN`
- Subqueries & correlated subqueries
- Common Table Expressions (CTEs), including recursive-style running calculations
- Window functions: `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`
- Running totals & moving averages
- Date & string functions
- NULL handling (`COALESCE`, `IS NULL`)
- Views for reusable reporting logic
- Indexing & query performance optimization

---

## 📁 Project Structure

```
SQL-Sales-Analysis/
│
├── README.md                  # Project overview (this file)
├── database_schema.sql        # Database & table creation, constraints, indexes
├── insert_data.sql            # Sample data population script (5,000+ rows)
├── data_cleaning.sql          # Data cleaning & standardization scripts
├── sales_analysis.sql         # 50+ documented business SQL queries
├── business_questions.md      # Full list of business questions answered
├── insights.md                # Written business insights & recommendations
├── advanced_interview_qna.md  # Bonus: SQL interview Q&A tied to this project
├── screenshots_placeholder.md # Placeholder for query output screenshots
├── LICENSE                    # MIT License
└── .gitignore                 # Standard ignore rules
```

---

## ▶️ How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/SQL-Sales-Analysis.git
   cd SQL-Sales-Analysis
   ```
2. Open your SQL client (MySQL Workbench, DBeaver, pgAdmin, etc.)
3. Run the schema file to create the database and tables:
   ```sql
   SOURCE database_schema.sql;
   ```
4. Load the data:
   ```sql
   SOURCE insert_data.sql;
   ```
5. Run the cleaning scripts:
   ```sql
   SOURCE data_cleaning.sql;
   ```
6. Explore the analysis:
   ```sql
   SOURCE sales_analysis.sql;
   ```
7. Cross-reference each query with `business_questions.md` and `insights.md` to see the business context and findings.

---

## 💡 Key Insights (Summary)

- A small segment of customers (~15–20%) contributes a disproportionate share of total revenue — a classic Pareto pattern worth targeting with loyalty programs.
- One region and category combination consistently outperforms others in profit margin, while a specific sub-category shows high sales but low/negative profit due to heavy discounting.
- Sales show a clear seasonal spike in specific months, useful for inventory and marketing planning.
- Certain shipping/payment modes correlate with higher average order value, suggesting checkout flow optimization opportunities.

*(Full details in `insights.md`.)*

---

## 📸 Screenshots

See `screenshots_placeholder.md` for guidance on capturing and embedding query output screenshots (recommended for the live GitHub version).

---

## 🚀 Future Improvements

- Connect this dataset to Power BI / Tableau for an interactive dashboard layer
- Add a Python (pandas) EDA notebook alongside the SQL analysis
- Automate data refresh via a simple ETL script
- Add RFM (Recency, Frequency, Monetary) customer segmentation
- Deploy queries as stored procedures for a reporting pipeline

---

## 🎓 Learning Outcomes

Building this project strengthened my ability to:
- Design a normalized schema from a raw business requirement
- Write clean, well-commented, production-style SQL
- Use window functions and CTEs to solve multi-step analytical problems
- Translate raw query output into clear business recommendations — not just numbers, but "so what"

---

## 📬 Contact

Feel free to connect if you have questions about this project or want to discuss the approach.

