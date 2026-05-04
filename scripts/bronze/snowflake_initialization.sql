/********************************************************************************
  SNOWFLAKE INITIALIZATION: External Stage & File Format Configuration
  
  Project: Olist E-commerce Data Pipeline
  Layer: Staging (S3 to Snowflake)
  Description: 
  This script sets up the infrastructure required to ingest optimized Parquet 
  data from Amazon S3 into Snowflake. It defines the storage parameters 
  and establishes a secure connection to the cloud storage bucket.
********************************************************************************/

-- 1. Create a dedicated File Format for Parquet files
-- Parquet is used to minimize data transfer costs and improve query performance.
-- Snappy compression is applied to ensure compatibility with the Athena-optimized layer.
CREATE OR REPLACE FILE FORMAT OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT
  TYPE = 'PARQUET'
  COMPRESSION = 'SNAPPY';

---

-- 2. Create an External Stage pointing to the S3 bucket
-- This stage serves as a bridge between AWS S3 and Snowflake.
CREATE OR REPLACE STAGE OLIST_DWH.STAGING.OLIST_S3_STAGE
  URL = 's3://olistproject-105558311683-us-east-1-an/optimized-bronze/'
  CREDENTIALS = (
    AWS_KEY_ID = '<YOUR_AWS_ACCESS_KEY_ID>' 
    AWS_SECRET_KEY = '<YOUR_AWS_SECRET_ACCESS_KEY>'
    AWS_TOKEN = '<YOUR_AWS_SESSION_TOKEN>'
  )
  FILE_FORMAT = OLIST_DWH.STAGING.OLIST_PARQUET_FORMAT;

---

-- 3. Verification Script
-- Run the following command to validate the connection and list available Parquet files.
LIST @OLIST_DWH.STAGING.OLIST_S3_STAGE;
