# Urban Basket Retail Sales Analysis

SQL analysis of 12 months of sales data for a 12-store grocery chain, covering revenue by category, month, and store.

## Dataset

Relational PostgreSQL database with 7 tables:

| Table | Rows |
|---|---|
| orders | 1,800 |
| order_items | 8,120 |
| customers | 260 |
| products | 50 |
| stores | 12 |
| employees | 60 |
| suppliers | 12 |

- **Period covered:** Aug 1, 2025 to Jul 25, 2026
- **Order statuses:** Delivered 1,624 · Returned 66 · Cancelled 62 · Pending 48

## Business questions

1. How much revenue did the business generate, and what is the average order value?
2. Which product categories drive the most revenue?
3. How does revenue change month to month?
4. How do the 12 stores compare?

## Method

- Revenue is calculated as `quantity × unit_price × (1 − discount_pct / 100)`, because `discount_pct` is stored as a percentage (0–15).
- Only **Delivered** orders are counted. Cancelled and Pending orders never produced revenue, and Returned orders gave it back.
- Queries use JOINs across `orders`, `order_items`, `products`, and `stores`, plus window functions for each category's share of total revenue.

All queries are in [`urban_basket_analysis.sql`](urban_basket_analysis.sql).

## Key findings

- **Net revenue:** 11.73M from 1,624 delivered orders (about 90% of all orders); average order value about 7,225.
- **Categories:** Fruits & Vegetables was the largest at 17.2% of revenue. The top 3 categories (Fruits & Vegetables, Household, Bakery) made up 46.2%. Personal Care was the smallest at 4.7%.
- **Monthly trend:** Revenue peaked in October 2025 (about 1.15M) and was lowest in February 2026 (about 0.73M). July 2026 is a partial month because the data ends on Jul 25.
- **Stores:** Revenue is spread fairly evenly. Rawalpindi Cantt was the top store at about 1.15M (9.8% of revenue); Multan Mall was the lowest at about 0.89M (7.6%).

## Data quality note

The `region` column in the `stores` table is inconsistent with store cities (for example, Lahore appears under two different regions). Results are therefore reported at store level rather than region level.

## Tools

PostgreSQL, SQL (pgAdmin 4)

## Repository contents

- `urban_basket_analysis.sql` – all queries used in this analysis
- `README.md` – project summary
- ![Executive Overview](executive-overview.jpg)
