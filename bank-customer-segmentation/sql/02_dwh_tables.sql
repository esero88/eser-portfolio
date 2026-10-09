-- =========================================
-- 🏦 BANK DWH - DIMENSION & FACT TABLES
-- =========================================

-- =========================================
-- 1. DIM CUSTOMER
-- =========================================
CREATE TABLE IF NOT EXISTS dwh.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(20),
    customer_dob DATE,
    customer_gender VARCHAR(10)
);

-- =========================================
-- 2. DIM LOCATION
-- =========================================
CREATE TABLE IF NOT EXISTS dwh.dim_location (
    location_key SERIAL PRIMARY KEY,
    customer_location VARCHAR(100)
);

-- =========================================
-- 3. DIM DATE
-- =========================================
CREATE TABLE IF NOT EXISTS dwh.dim_date (
    date_key INT PRIMARY KEY,
    date DATE,
    year INT,
    month INT,
    day INT
);

-- =========================================
-- 4. FACT TRANSACTIONS
-- =========================================
CREATE TABLE IF NOT EXISTS dwh.fact_transactions (
    transaction_key SERIAL PRIMARY KEY,
    customer_key INT,
    location_key INT,
    date_key INT,
    transaction_amount NUMERIC(18,2),
    account_balance NUMERIC(18,2)
);

-- =========================================
-- 5. FOREIGN KEYS
-- =========================================

ALTER TABLE dwh.fact_transactions
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_key)
REFERENCES dwh.dim_customer(customer_key);

ALTER TABLE dwh.fact_transactions
ADD CONSTRAINT fk_location
FOREIGN KEY (location_key)
REFERENCES dwh.dim_location(location_key);

ALTER TABLE dwh.fact_transactions
ADD CONSTRAINT fk_date
FOREIGN KEY (date_key)
REFERENCES dwh.dim_date(date_key);