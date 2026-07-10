# 📸 Screenshots

This file is a placeholder guide for adding query-output screenshots to the live GitHub repository. Static SQL/Markdown files can't show live output, so recruiters often appreciate visual proof the queries actually run.

## Recommended Screenshots to Capture

1. **Schema diagram** — an ERD (Entity Relationship Diagram) showing `customers`, `products`, and `orders` with their relationships. Most SQL clients (MySQL Workbench, DBeaver) can auto-generate this from `database_schema.sql`.
2. **Q6 output** — the headline revenue/profit/margin summary (proves the "so what" number backing `insights.md`).
3. **Q7 output** — region-level revenue and margin table.
4. **Q30 output** — top sub-categories per category (shows a CTE + window function result).
5. **Q39/Q40 output** — the running total and moving average charts, ideally screenshotted from a client that renders a small line chart (e.g., DBeaver's result grid chart view).
6. **EXPLAIN output (Q53)** — proves the index is actually being used, a nice technical-depth signal for interviewers.

## How to Add Screenshots

1. Create a `/screenshots` folder in the repo root.
2. Name files descriptively: `01_erd_diagram.png`, `02_revenue_summary.png`, etc.
3. Embed them in `README.md` under the **Screenshots** section using:
   ```markdown
   ![Revenue Summary](screenshots/02_revenue_summary.png)
   ```
4. Keep screenshots cropped tightly to the result grid — no need to show the entire IDE window.

## Suggested Tools for Capturing Clean Screenshots

- **DBeaver** (free, cross-platform) — clean result grids and has a built-in chart view for numeric results.
- **MySQL Workbench** — good for ERD diagrams specifically.
- **TablePlus** — polished UI, popular in professional portfolios.

*(This file exists so the repository structure is complete even before screenshots are captured — replace this note with actual embedded images once you've run the queries locally.)*
