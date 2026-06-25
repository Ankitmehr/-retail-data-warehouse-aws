-- ============================================
-- Project: Retail Data Warehouse - AWS
-- Phase 4: Star Schema (Dimensional Modeling)
-- Author: Ankit Mehra
-- Date: June 2026
-- ============================================

-- Step 1: Create Dimension Tables
CREATE TABLE dim_customers (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50),
    country VARCHAR(100)
);

CREATE TABLE dim_products (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    stock_code VARCHAR(50),
    description VARCHAR(500),
    unit_price NUMERIC(10, 2)
);

-- Step 2: Create Fact Table
CREATE TABLE fact_orders (
    order_id VARCHAR(50),
    customer_key INT,
    product_key INT,
    quantity INTEGER,
    unit_price NUMERIC(10, 2),
    total_amount NUMERIC(12, 2),
    invoice_date TIMESTAMP,
    FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_products(product_key)
);

-- Step 3: Populate Dimensions
INSERT INTO dim_customers (customer_id, country)
SELECT DISTINCT TRIM(CustomerID), TRIM(Country)
FROM staging_retail
WHERE CustomerID IS NOT NULL AND TRIM(CustomerID) != '';

INSERT INTO dim_products (stock_code, description, unit_price)
SELECT DISTINCT TRIM(StockCode), TRIM(Description), MAX(UnitPrice)
FROM staging_retail
WHERE StockCode IS NOT NULL AND TRIM(StockCode) != ''
GROUP BY TRIM(StockCode), TRIM(Description);

-- Step 4: Populate Fact Table
INSERT INTO fact_orders (order_id, customer_key, product_key, 
quantity, unit_price, total_amount, invoice_date)
SELECT  
    TRIM(s.InvoiceNo),
    c.customer_key,
    p.product_key,
    s.Quantity,
    s.UnitPrice,
    (s.Quantity * s.UnitPrice) AS total_amount,
    TO_TIMESTAMP(TRIM(s.InvoiceDate), 'DD-MM-YYYY HH24:MI')  
FROM staging_retail s
LEFT JOIN dim_customers c ON TRIM(s.CustomerID) = c.customer_id
LEFT JOIN dim_products p ON TRIM(s.StockCode) = p.stock_code 
    AND TRIM(s.Description) = p.description;