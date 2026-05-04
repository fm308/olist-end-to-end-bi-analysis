/********************************************************************************
  SILVER LAYER: Data Transformation & Standardization
  
  Purpose: 
  Cleans and normalizes staging data for the Silver (Trusted) layer.
  
  Key Features:
  - Text Normalization: Standardizes city names (removes diacritics/special chars).
  - Data Quality: Filters geographic coordinates and validates record formats.
  - Business Logic: Calculates total values and handles missing/null attributes.
  - Performance: Aggregates geolocation data for improved join efficiency.
********************************************************************************/

/********************************************************************************
  SILVER LAYER: Data Transformation & Standardization
  
  Purpose: 
  Cleans and normalizes staging data for the Silver (Trusted) layer.
  
  Key Features:
  - Text Normalization: Standardizes city names (removes diacritics/special chars).
  - Data Quality: Filters geographic coordinates and validates record formats.
  - Business Logic: Calculates total values and handles missing/null attributes.
  - Performance: Aggregates geolocation data for improved join efficiency.
********************************************************************************/

CREATE OR REPLACE PROCEDURE OLIST_DWH.SILVER.TRANSFORM_STAGING_TO_SILVER()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- 1. order_payments_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.order_payments_silver AS
    SELECT
        order_id,
        payment_sequential,
        REPLACE(payment_type, '_', ' ') AS payment_type,
        NULLIF(payment_installments, 0) AS payment_installments,
        payment_value
    FROM OLIST_DWH.STAGING.OLIST_ORDER_PAYMENTS;

    -- 2. reviews_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.reviews_silver AS
    SELECT 
        TRIM(review_id) AS review_id,
        TRIM(order_id) AS order_id,
        NULLIF(review_score, 0) AS review_score,
        TRIM(COALESCE(NULLIF(review_comment_title, ''), 'No Message')) AS review_comment_title,
        TRIM(COALESCE(NULLIF(review_comment_mess, ''), 'No Message')) AS review_comment_mess,
        review_create_date,
        review_answer_timestamp
    FROM OLIST_DWH.STAGING.OLIST_ORDER_REVIEWS
    WHERE
        RLIKE(TRIM(review_id), '^[0-9a-fA-F]{32}$') 
        AND RLIKE(TRIM(order_id), '^[0-9a-fA-F]{32}$');

    -- 3. order_items_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.order_items_silver AS
    SELECT 
        *,
        price + freight_value AS total_item_value
    FROM OLIST_DWH.STAGING.OLIST_ORDER_ITEMS;

    -- 4. orders_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.orders_silver AS
    SELECT *
    FROM OLIST_DWH.STAGING.OLIST_ORDERS;

    -- 5. sellers_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.sellers_silver AS
    SELECT
        seller_id,
        seller_zip_pref,
        CASE 
            WHEN TRIM(seller_city) RLIKE '^[0-9]+$' THEN 'Unknown'
            WHEN TRIM(seller_city) = '' THEN 'Unknown'
            ELSE 
                INITCAP(
                    TRIM(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                TRANSLATE(LOWER(seller_city), 'ãáâàéêíóôõúüç', 'aaaaeeiooouuc'),
                                ' ([-/]|sp| -).*$', ''
                            ),
                            '[^a-z0-9 ]', ''
                        )
                    )
                )
        END AS seller_city,
        COALESCE(NULLIF(UPPER(TRIM(seller_state)), ''), 'N/A') AS seller_state
    FROM OLIST_DWH.STAGING.olist_sellers;

    -- 6. products_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.products_silver AS
    SELECT
        TRIM(product_id) AS product_id,
        INITCAP(REPLACE(prod_cat_name, '_', ' ')) AS prod_cat_name,
        COALESCE(prod_name_lenght, 0) AS product_name_length,
        COALESCE(prod_desc_lenght, 0) AS product_description_length,
        COALESCE(prod_photo_qty, 0) AS product_photos_qty,
        NULLIF(prod_weight, 0) AS product_weight_g,
        NULLIF(prod_length_cm, 0) AS product_length,
        NULLIF(prod_height_cm, 0) AS prod_height_cm,
        NULLIF(prod_width_cm, 0) AS prod_width_cm
    FROM OLIST_DWH.STAGING.OLIST_PRODUCTS;

    -- 7. geolocation
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.geolocation AS
    SELECT
        geoloc_zip_code_prefix,
        ROUND(AVG(geoloc_lat), 6) AS geolocation_lat,
        ROUND(AVG(geoloc_lng), 6) AS geolocation_lng,
        MAX(
            INITCAP(
                TRIM(
                    REGEXP_REPLACE(
                        TRANSLATE(LOWER(geoloc_city),
                        'ãáâàéêíóôõúüç', 'aaaaeeiooouuc'), '[^a-z0-9 ]', '')
                )
            )
        ) AS geolocation_city,
        MAX(UPPER(TRIM(geoloc_state))) AS geolocation_state
    FROM OLIST_DWH.STAGING.OLIST_GEOLOCATION
    WHERE 
        geoloc_lat BETWEEN -34 AND 6
        AND geoloc_lng BETWEEN -74 AND -34
    GROUP BY 1;

    -- 8. customers_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.customers_silver AS
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        INITCAP(
            TRIM(
                REGEXP_REPLACE(
                    TRANSLATE(LOWER(customer_city), 
                        'ãáâàéêíóôõúüç', 
                        'aaaaeeiooouuc'),
                '[^a-z0-9 ]', '')
            )
        ) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state
    FROM OLIST_DWH.STAGING.OLIST_CUSTOMERS;

    -- 9. cat_names_trans_silver
    CREATE OR REPLACE TABLE OLIST_DWH.SILVER.cat_names_trans_silver AS
    SELECT  
        INITCAP(REPLACE(prod_cat_name, '_', ' ')) AS prod_cat_name,
        INITCAP(REPLACE(prod_cat_name_eng, '_', ' ')) AS prod_cat_name_english
    FROM OLIST_DWH.STAGING.CAT_NAME_TRANS;

    RETURN 'Silver Layer transformation completed successfully.';
END;
$$;

-- Call the procedure to execute:
-- CALL OLIST_DWH.SILVER.TRANSFORM_STAGING_TO_SILVER();
