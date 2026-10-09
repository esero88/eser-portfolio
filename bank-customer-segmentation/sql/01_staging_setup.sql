-- =========================================
-- 🏦 BANK DWH - INITIAL SETUP
-- =========================================

-- 1. SCHEMA CREATION
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dwh;
CREATE SCHEMA IF NOT EXISTS datamart;

-- =========================================
-- 2. STAGING TABLE (CLEAN DATA LANDING)
-- =========================================

CREATE TABLE IF NOT EXISTS staging.transactions_clean (
    transaction_id VARCHAR(20),
    customer_id VARCHAR(20),
    customer_dob DATE,
    customer_gender VARCHAR(10),
    customer_location VARCHAR(100),
    customer_account_balance NUMERIC(18,2),
    transaction_date DATE,
    transaction_time INT,
    transaction_amount_inr NUMERIC(18,2)
);

-- =========================================
-- 3. DATA CHECK
-- =========================================

SELECT COUNT(*) FROM staging.transactions_clean;

SELECT *
FROM staging.transactions_clean
LIMIT 10;