/*
This script executes the transformation of raw data from the initial CSV-based Staging tables into the Optimized Bronze Layer. 
It utilizes the CTAS (Create Table As Select) pattern to convert data into Apache Parquet, a high-performance columnar storage format.

Key Actions performed by this script:

- Format Conversion: Transmutes row-based CSV data into columnar Parquet format to significantly reduce data scanning costs in AWS Athena.

- Compression Implementation: Applies Snappy compression to minimize S3 storage footprint and accelerate I/O operations.

- Performance Tuning: Reorganizes data structures to enable faster analytical queries for downstream processes in Snowflake.

- Schema Enforcement: Ensures data integrity by persisting the metadata defined in the staging layer into the optimized physical storage.
*/

-- olist_orders to parquet
CREATE TABLE olist_orders_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_orders/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    order_id ,
    customer_id ,
    order_status ,
    order_purchase_timestamp ,
    order_approved_at ,
    order_delivered_carrier_date ,
    order_delivered_customer_date ,
    order_estimated_delivery_date 
FROM olist_orders;


-- olist_customers to parquet
CREATE TABLE olist_customers_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_customers/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    customer_id ,
    customer_unique_id ,
    customer_zip_code_prefix ,
    customer_city ,
    customer_state 
FROM olist_customers;


-- olist_geolocation to parquet
CREATE TABLE olist_geolocation_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_geolocation/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    geoloc_zip_code_prefix ,
    geoloc_lat ,
    geoloc_lng ,
    geoloc_city ,
    geoloc_state 
FROM olist_geolocation;


-- olist_customers to parquet
CREATE TABLE olist_order_items_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_order_items/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    order_id ,
    order_item_id ,
    product_id ,
    seller_id ,
    shipping_limit_date ,
    price ,
    freight_value 
FROM olist_order_items;


-- olist_customers to parquet
CREATE TABLE olist_order_payments_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_order_payments/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    order_id ,
    payment_sequential ,
    payment_type ,
    payment_installments ,
    payment_value 
FROM olist_order_payments;


-- olist_order_reviews to parquet
CREATE TABLE olist_order_reviews_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_order_reviews/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    review_id ,
    order_id ,
    review_score ,
    review_comment_title ,
    review_comment_mess ,
    review_create_date ,
    review_answer_timestamp  
FROM olist_order_reviews;


-- olist_products to parquet
CREATE TABLE olist_products_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_products/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    product_id ,
    prod_cat_name ,
    prod_name_lenght ,
    prod_desc_lenght ,
    prod_photo_qty ,
    prod_weight ,
    prod_length_cm ,
    prod_height_cm ,
    prod_width_cm  
FROM olist_products;


-- olist_sellers to parquet
CREATE TABLE olist_sellers_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/olist_sellers/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    seller_id ,
    seller_zip_pref ,
    seller_city ,
    seller_state 
FROM olist_sellers;


-- cat_name_trans to parquet
CREATE TABLE cat_name_trans_parquet
WITH (
      format = 'PARQUET',
      external_location = 's3://olistproject-105558311683-us-east-1-an/olist_project/parquet/category_name_translation/',
      parquet_compression = 'SNAPPY'
)
AS SELECT 
    prod_cat_name ,
    prod_cat_name_eng 
FROM cat_name_trans;
