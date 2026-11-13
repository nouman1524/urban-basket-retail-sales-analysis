-- =====================================================================
-- Urban Basket Retail Sales Analysis (PostgreSQL)
-- Database: URBAN_BASKET_POWERBI
-- Tables: customers, employees, order_items, orders, products, stores, suppliers
-- Revenue definition: quantity * unit_price * (1 - discount_pct / 100)
--                     counted for Delivered orders only
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. DATA PROFILING
-- ---------------------------------------------------------------------

-- 1.1 Row count of every table
SELECT table_name,
       (xpath('/row/c/text()',
              query_to_xml(format('SELECT COUNT(*) AS c FROM %I.%I', table_schema, table_name),
                           false, true, '')))[1]::text::int AS row_count
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 1.2 Columns and data types
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 1.3 Date range and coverage
SELECT MIN(order_date)             AS first_order,
       MAX(order_date)             AS last_order,
       COUNT(*)                    AS orders,
       COUNT(DISTINCT customer_id) AS customers_who_ordered,
       COUNT(DISTINCT store_id)    AS stores_with_orders
FROM orders;

-- 1.4 Order status breakdown
SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 1.5 How discounts are stored (percentage, not fraction)
SELECT MIN(discount_pct)           AS min_discount,
       MAX(discount_pct)           AS max_discount,
       ROUND(AVG(discount_pct), 2) AS avg_discount
FROM order_items;


-- ---------------------------------------------------------------------
-- 2. REVENUE ANALYSIS (Delivered orders only)
-- ---------------------------------------------------------------------

-- 2.1 Total net revenue and average order value
SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
             / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';

-- 2.2 Revenue by category, with share of total
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue,
       ROUND(100.0 * SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
             / SUM(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))) OVER (), 1) AS pct_of_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY net_revenue DESC;

-- 2.3 Monthly revenue trend (note: Jul 2026 is a partial month, data ends Jul 25)
SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY 1
ORDER BY 1;

-- 2.4 Revenue by store
-- Note: stores.region labels are inconsistent with cities (e.g. Lahore appears
-- in two regions), so results are reported at store level, not region level.
SELECT s.store_name, s.region, s.city,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN stores s ON s.store_id = o.store_id
WHERE o.order_status = 'Delivered'
GROUP BY s.store_name, s.region, s.city
ORDER BY net_revenue DESC;
