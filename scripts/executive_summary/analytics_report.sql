/* 
============================================================
OLIST E-COMMERCE EXECUTIVE SUMMARY
Scope: Sales Performance, Customer Growth, LTV & Data Quality
============================================================
*/


-- 1. KEY METRICS (High-level Overview)
SELECT 'Total Sales' AS measure_name, ROUND(SUM(price), 2) AS measure_value FROM OLIST_DWH.GOLD.FACT_SALES_GOLD
UNION ALL
SELECT 'Average price', ROUND(AVG(price), 2) FROM OLIST_DWH.GOLD.FACT_SALES_GOLD
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_id) FROM OLIST_DWH.GOLD.FACT_SALES_GOLD
UNION ALL
SELECT 'Total Nr. Customers', COUNT(DISTINCT customer_unique_id) FROM OLIST_DWH.GOLD.DIM_CUSTOMERS_GOLD
UNION ALL
SELECT 'Total Nr. Categories', COUNT(DISTINCT category_name_english) FROM OLIST_DWH.GOLD.DIM_PROD_NAMES_GOLD
UNION ALL
SELECT 'Average weight', ROUND(AVG(product_weight_g), 0) FROM OLIST_DWH.GOLD.DIM_PROD_NAMES_GOLD
UNION ALL SELECT 'Customers who have not placed an order yet', COUNT(*)
FROM (
SELECT DISTINCT 
customer_unique_id
FROM OLIST_DWH.GOLD.DIM_CUSTOMERS_GOLD
WHERE customer_id NOT IN (SELECT customer_id FROM OLIST_DWH.GOLD.FACT_SALES_GOLD)
)t



-- 2. MONTH OVER MONTH GROWTH ANALYSIS (Advanced Window Functions)
  
WITH monthly_metrics AS(

SELECT
DATE_TRUNC(month, f.order_purchase_timestamp) AS order_time,
    ROUND(SUM(f.price), 1) AS old_price,
    COUNT(c.customer_unique_id) AS old_cust
FROM OLIST_DWH.GOLD.FACT_SALES_GOLD f
 LEFT JOIN OLIST_DWH.GOLD.DIM_CUSTOMERS_GOLD c
    ON f.customer_id = c.customer_id
GROUP BY 1
),

lagged_metrics AS (

SELECT
order_time,
old_price,
LAG(old_price) OVER (ORDER BY order_time) AS prev_month_rev,
old_cust,
LAG(old_cust) OVER (ORDER BY order_time) AS prev_month_cust
FROM monthly_metrics
)


SELECT
order_time,
old_price,
prev_month_rev,
CASE WHEN old_price > prev_month_rev THEN 'increase'
     WHEN old_price < prev_month_rev THEN 'decrease'
     WHEN prev_month_rev IS NULL THEN 'first_month'
     ELSE 'no change'
END AS mon_growth,
SUM(old_price) OVER (ORDER BY order_time) AS running_total_revenue,
old_cust,
prev_month_cust,
CASE 
    WHEN old_cust > prev_month_cust THEN 'Customer growth'
    WHEN old_cust < prev_month_cust THEN 'Customer loss'
    WHEN prev_month_cust IS NULL THEN 'first month'
    ELSE 'no change'
END AS cust_growth,
SUM(old_cust) OVER (ORDER BY order_time) AS running_total_customers
FROM lagged_metrics
ORDER BY order_time



-- 3. CUSTOMER LIFETIME VALUE (LTV) - Top 10 High Spenders

WITH order_spending AS (
    SELECT
        f.customer_id,
        c.customer_unique_id,
        SUM(f.total_item_value) AS total_spend
    FROM OLIST_DWH.GOLD.FACT_SALES_GOLD f
    LEFT JOIN OLIST_DWH.GOLD.DIM_CUSTOMERS_GOLD c ON f.customer_id = c.customer_id
    GROUP BY 1, 2
)
SELECT
    customer_unique_id,
    ROUND(SUM(total_spend), 2) AS ltv_value,
    COUNT(customer_id) AS orders_count
FROM order_spending
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
