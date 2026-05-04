/********************************************************************************
  SNOWFLAKE INGESTION: S3 Parquet to Staging Layer
  
  Purpose: 
  Defines the structured Staging schema and executes data loading from S3.
  
  Key Features:
  - Schema Enforcement: Explicitly defines data types (TIMESTAMP, FLOAT, INT).
  - Automated Mapping: Uses 'MATCH_BY_COLUMN_NAME' for efficient Parquet ingestion.
  - Error Handling: Implements 'ON_ERROR = CONTINUE' for pipeline resilience.
  - Validation: Includes post-load record verification.
********************************************************************************/

-- olist_orders

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_orders (
    order_id STRING,
    customer_id STRING,
    order_status STRING,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

COPY INTO OLIST_DWH.STAGING.olist_orders
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_orders/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.olist_orders LIMIT 10;


-- olist_customers

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_customers (
    customer_id STRING,
    customer_unique_id STRING,
    customer_zip_code_prefix STRING,
    customer_city STRING,
    customer_state STRING
);
SELECT * FROM OLIST_DWH.STAGING.olist_customers

COPY INTO OLIST_DWH.STAGING.olist_customers
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_customers/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';


-- olist_geolocation

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_geolocation (
    geoloc_zip_code_prefix STRING,
    geoloc_lat FLOAT,
    geoloc_lng FLOAT,
    geoloc_city STRING,
    geoloc_state STRING
);

COPY INTO OLIST_DWH.STAGING.olist_geolocation
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_geolocation/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.olist_geolocation LIMIT 10



-- olist_order_items

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_order_items (
    order_id STRING,
    order_item_id INTEGER,
    product_id STRING,
    seller_id STRING,
    shipping_limit_date TIMESTAMP,
    price FLOAT,
    freight_value FLOAT
);

COPY INTO OLIST_DWH.STAGING.olist_order_items
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_order_items/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.olist_order_items LIMIT 10


-- olist_order_payments

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_order_payments (
    order_id STRING,
    payment_sequential INTEGER,
    payment_type STRING,
    payment_installments INTEGER,
    payment_value FLOAT
);

COPY INTO OLIST_DWH.STAGING.olist_order_payments
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_order_payments/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.olist_order_payments 


-- olist_order_reviews

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_order_reviews (
    review_id STRING,
    order_id STRING,
    review_score INTEGER,
    review_comment_title STRING,
    review_comment_mess STRING,
    review_create_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY INTO OLIST_DWH.STAGING.olist_order_reviews
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_order_reviews/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.olist_order_reviews LIMIT 10


-- olist_products

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_products (
    product_id STRING,
    prod_cat_name STRING,
    prod_name_lenght FLOAT,
    prod_desc_lenght FLOAT,
    prod_photo_qty FLOAT,
    prod_weight FLOAT,
    prod_length_cm FLOAT,
    prod_height_cm FLOAT,
    prod_width_cm FLOAT
);

COPY INTO OLIST_DWH.STAGING.olist_products
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_products/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.olist_products LIMIT 10


-- olist_sellers

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.olist_sellers (
    seller_id STRING,
    seller_zip_pref STRING,
    seller_city STRING,
    seller_state STRING
);

COPY INTO OLIST_DWH.STAGING.olist_sellers
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/olist_sellers/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.olist_sellers LIMIT 10


-- olist_sellers

CREATE OR REPLACE TABLE OLIST_DWH.STAGING.cat_name_trans (
    prod_cat_name STRING,
    prod_cat_name_eng STRING
);

COPY INTO OLIST_DWH.STAGING.cat_name_trans
FROM @OLIST_DWH.STAGING.OLIST_S3_STAGE/olist_project/parquet/category_name_translation/
FILE_FORMAT = (FORMAT_NAME = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

SELECT * FROM OLIST_DWH.STAGING.cat_name_trans LIMIT 10
