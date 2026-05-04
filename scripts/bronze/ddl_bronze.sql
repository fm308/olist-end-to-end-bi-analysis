/****************************************************************
STAGING AREA: Defining External Tables based on S3 CSV Data Sources
Projekt: Olist E-commerce Analysis
*****************************************************************/

-- Olist customers table
DROP TABLE IF EXISTS olist_customers;
CREATE EXTERNAL TABLE IF NOT EXISTS olist_customers (
    customer_id STRING,
    customer_unique_id STRING,
    customer_zip_code_prefix STRING,
    customer_city STRING,
    customer_state STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_customers/'
TBLPROPERTIES ('skip.header.line.count'='1');


-- Olis geolocation table

DROP TABLE IF EXISTS olist_geolocation;
CREATE EXTERNAL TABLE IF NOT EXISTS olist_geolocation (
    geoloc_zip_code_prefix STRING,
    geoloc_lat STRING,
    geoloc_lng STRING,
    geoloc_city STRING,
    geoloc_state STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_geolocation/'
TBLPROPERTIES ('skip.header.line.count'='1');


-- Olist order items table

DROP TABLE IF EXISTS olist_order_items;
CREATE EXTERNAL TABLE IF NOT EXISTS olist_order_items (
    order_id STRING,
    order_item_id STRING,
    product_id STRING,
    seller_id STRING,
    shipping_limit_date STRING,
    price STRING,
    freight_value STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_order_items/'
TBLPROPERTIES ('skip.header.line.count'='1');



-- Olist order payments table

DROP TABLE IF EXISTS olist_order_payments;
CREATE EXTERNAL TABLE IF NOT EXISTS olist_order_payments (
    order_id STRING,
    payment_sequential STRING,
    payment_type STRING,
    payment_installments STRING,
    payment_value STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_order_payments/'
TBLPROPERTIES ('skip.header.line.count'='1');


-- Olist order reviews table

DROP TABLE IF EXISTS olist_order_reviews;
CREATE EXTERNAL TABLE IF NOT EXISTS olist_order_reviews (
    review_id STRING,
    order_id STRING,
    review_score STRING,
    review_comment_title STRING,
    review_comment_mess STRING,
    review_create_date STRING,
    review_answer_timestamp STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_order_reviews/'
TBLPROPERTIES ('skip.header.line.count'='1');


-- Olist orders table

DROP TABLE IF EXISTS olist_orders;

CREATE EXTERNAL TABLE olist_orders (
     order_id STRING,
    customer_id STRING,
    order_status STRING,
    order_purchase_timestamp STRING,
    order_approved_at STRING,
    order_delivered_carrier_date STRING,
    order_delivered_customer_date STRING,
    order_estimated_delivery_date STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
LOCATION 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_orders/'
TBLPROPERTIES ('skip.header.line.count'='1');


-- Olist products table

DROP TABLE IF EXISTS olist_products;
CREATE EXTERNAL TABLE IF NOT EXISTS olist_products (
    product_id STRING,
    prod_cat_name STRING,
    prod_name_lenght STRING,
    prod_desc_lenght STRING,
    prod_photo_qty STRING,
    prod_weight STRING,
    prod_length_cm STRING,
    prod_height_cm STRING,
    prod_width_cm STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_products/'
TBLPROPERTIES ('skip.header.line.count'='1');  


-- Olist sellers table

DROP TABLE IF EXISTS olist_sellers;
CREATE EXTERNAL TABLE IF NOT EXISTS olist_sellers (
    seller_id STRING,
    seller_zip_pref STRING,
    seller_city STRING,
    seller_state STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/olist_sellers/'
TBLPROPERTIES ('skip.header.line.count'='1'); 


-- category name translation table 

DROP TABLE IF EXISTS cat_name_trans;
CREATE EXTERNAL TABLE IF NOT EXISTS cat_name_trans (
    prod_cat_name STRING,
    prod_cat_name_eng STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
location 's3://olistproject-105558311683-us-east-1-an/olist_project/category_name_translation/'
TBLPROPERTIES ('skip.header.line.count'='1'); 
