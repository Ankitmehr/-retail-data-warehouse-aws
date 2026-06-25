-- ============================================
-- Project: Retail Data Warehouse - AWS
-- Phase 5: Analytical SQL Layer
-- Author: Ankit Mehra
-- Date: June 2026
-- ============================================

-- Query 1: Monthly Financial Run Rate
SELECT  
    DATE_TRUNC('month', invoice_date) AS order_month,
    SUM(total_amount) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM fact_orders
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY order_month ASC;

-- Query 2: Top 10 Best-Selling Products
SELECT  
    p.stock_code,
    p.description,
    SUM(f.quantity) AS total_quantity_sold,
    SUM(f.total_amount) AS total_revenue_generated
FROM fact_orders f
JOIN dim_products p ON f.product_key = p.product_key
GROUP BY p.stock_code, p.description
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Query 3: Customer Lifetime Value
SELECT  
    c.customer_id,
    c.country,
    COUNT(DISTINCT f.order_id) AS total_distinct_orders,
    SUM(f.total_amount) AS lifetime_value
FROM fact_orders f
JOIN dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_id, c.country
ORDER BY lifetime_value DESC
LIMIT 10;

-- Query 4: Customer Retention Rate
WITH customer_order_counts AS (
    SELECT customer_key, COUNT(DISTINCT order_id) AS order_count
    FROM fact_orders
    GROUP BY customer_key
)
SELECT  
    COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    ROUND((COUNT(CASE WHEN order_count > 1