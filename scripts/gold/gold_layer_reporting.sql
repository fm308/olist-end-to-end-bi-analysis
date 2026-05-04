/********************************************************************************
  GOLD LAYER: Business & Analytical Views (Star Schema)
  
  Purpose: 
  Final analytical layer designed for Power BI consumption. 
  Transforms Silver data into Dimensions and Fact tables.
  
  Key Features:
  - Delivery Performance: Calculates actual vs. estimated delivery times.
  - Localization: Joins geolocation data for both customers and sellers.
  - Translation: Maps Portuguese category names to English for global reporting.
  - Business Logic: Filters for 'delivered' orders and handles categorization.
********************************************************************************/

CREATE OR REPLACE PROCEDURE OLIST_DWH.GOLD.DEPLOY_GOLD_LAYER()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- 1. dim_sellers_gold: Sellers with geolocation coordinates
    CREATE OR REPLACE VIEW OLIST_DWH.GOLD.DIM_SELLERS_GOLD AS
    SELECT
        s.*,
        g.geolocation_lat AS seller_lat,
        g.geolocation_lng AS seller_lng
    FROM OLIST_DWH.SILVER.SELLERS_SILVER s
    LEFT JOIN OLIST_DWH.SILVER.GEOLOCATION g
        ON s.seller_zip_pref = g.geoloc_zip_code_prefix;

    -- 2. dim_prod_names_gold: Products with English category translations
    CREATE OR REPLACE VIEW OLIST_DWH.GOLD.DIM_PROD_NAMES_GOLD AS
    SELECT
        p.*,
        COALESCE(t.prod_cat_name_english, p.prod_cat_name) AS category_name_english
    FROM OLIST_DWH.SILVER.PRODUCTS_SILVER p
    LEFT JOIN OLIST_DWH.SILVER.CAT_NAMES_TRANS_SILVER t
        ON p.prod_cat_name = t.PROD_CAT_NAME;

    -- 3. dim_customers_gold: Customers with geolocation coordinates
    CREATE OR REPLACE VIEW OLIST_DWH.GOLD.DIM_CUSTOMERS_GOLD AS
    SELECT
        c.customer_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        g.geolocation_lat AS customer_lat,
        g.geolocation_lng AS customer_lng
    FROM OLIST_DWH.SILVER.CUSTOMERS_SILVER c
    LEFT JOIN OLIST_DWH.SILVER.GEOLOCATION g
        ON c.customer_zip_code_prefix = g.geoloc_zip_code_prefix;

    -- 4. fact_sales_gold: Comprehensive sales fact table with business KPIs
    CREATE OR REPLACE VIEW OLIST_DWH.GOLD.FACT_SALES_GOLD AS
    SELECT
        oi.order_id,
        oi.product_id,
        oi.seller_id,
        o.customer_id,
        COALESCE(t.prod_cat_name_english, 'Other') AS product_category,
        op.payment_type,
        oi.price,
        oi.freight_value,
        oi.total_item_value,
        -- Delivery Performance Metrics
        DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date) AS actual_delivery_days,
        DATEDIFF('day', o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_diff_vs_estimated,
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On Time'
            ELSE 'Delayed'
        END AS delivery_status_performance,
        r.review_score,
        o.order_purchase_timestamp
    FROM OLIST_DWH.SILVER.ORDER_ITEMS_SILVER oi
    JOIN OLIST_DWH.SILVER.ORDERS_SILVER o 
        ON oi.order_id = o.order_id
    LEFT JOIN OLIST_DWH.SILVER.PRODUCTS_SILVER p
        ON oi.product_id = p.product_id
    LEFT JOIN OLIST_DWH.SILVER.CAT_NAMES_TRANS_SILVER t
        ON p.prod_cat_name = t.prod_cat_name
    LEFT JOIN OLIST_DWH.SILVER.REVIEWS_SILVER r
        ON oi.order_id = r.order_id
    LEFT JOIN OLIST_DWH.SILVER.ORDER_PAYMENTS_SILVER op
        ON oi.order_id = op.order_id
    WHERE o.order_status = 'delivered';

    RETURN 'Gold Layer views deployed successfully.';
END;
$$;

-- Call the procedure to deploy all views:
-- CALL OLIST_DWH.GOLD.DEPLOY_GOLD_LAYER();
