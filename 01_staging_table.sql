-- ============================================
-- Project: Retail Data Warehouse - AWS
-- Phase 3: Staging Layer
-- Author: Ankit Mehra
-- Date: June 2026
-- ============================================

-- Step 1: Create Staging Table (Landing Zone)
CREATE TABLE staging_retail (
    CustomerID VARCHAR(50),
    StockCode VARCHAR(50),
    Description VARCHAR(500),
    Quantity INTEGER,
    InvoiceDate VARCHAR(50),
    UnitPrice NUMERIC(10, 2),
    InvoiceNo VARCHAR(50),
    Country VARCHAR(100)
);

-- Step 2: Load Data from S3
COPY staging_retail
FROM 's3://ankit-s3-redshifts/online_retail.csv'
IAM_ROLE 'arn:aws:iam::058264181486:role/Redshift-S3-Read-Access'
FORMAT AS CSV
IGNOREHEADER 1;

-- Step 3: Verify Data Load
SELECT COUNT(*) AS total_records 
FROM staging_retail;
-- Expected: 541,909 records