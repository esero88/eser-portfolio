-- =========================================
-- 🏦 ETL LOAD - STAGING → DWH
-- =========================================

-- =========================================
-- 0. CLEAN TARGET TABLES (FULL REFRESH)
-- =========================================

TRUNCATE TABLE dwh.fact_transactions RESTART IDENTITY CASCADE;
TRUNCATE TABLE dwh.dim_customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE dwh.dim_location RESTART IDENTITY CASCADE;
TRUNCATE TABLE dwh.dim_date RESTART IDENTITY CASCADE;

-- =========================================
-- 1. LOAD DIM CUSTOMER
-- =========================================

INSERT INTO dwh.dim_customer (customer_id, customer_dob, customer_gender)
SELECT DISTINCT
    customer_id,
    customer_dob,
    customer_gender
FROM staging.transactions_clean;

-- =========================================
-- 2. LOAD DIM LOCATION
-- =========================================

INSERT INTO dwh.dim_location (customer_location)
SELECT DISTINCT
    customer_location
FROM staging.transactions_clean;

-- =========================================
-- 3. LOAD DIM DATE
-- =========================================

INSERT INTO dwh.dim_date (date_key, date, year, month, day)
SELECT DISTINCT
    TO_CHAR(transaction_date, 'YYYYMMDD')::INT,
    transaction_date,
    EXTRACT(YEAR FROM transaction_date),
    EXTRACT(MONTH FROM transaction_date),
    EXTRACT(DAY FROM transaction_date)
FROM staging.transactions_clean;

-- =========================================
-- 4. LOAD FACT TABLE
-- =========================================

INSERT INTO dwh.fact_transactions (
    customer_key,
    location_key,
    date_key,
    transaction_amount,
    account_balance
)
SELECT
    dc.customer_key,
    dl.location_key,
    TO_CHAR(s.transaction_date, 'YYYYMMDD')::INT,
    s.transaction_amount_inr,
    s.customer_account_balance
FROM staging.transactions_clean s
JOIN dwh.dim_customer dc
    ON s.customer_id = dc.customer_id
JOIN dwh.dim_location dl
    ON s.customer_location = dl.customer_location;

-- =========================================
-- 5. INDEXES
-- =========================================

CREATE INDEX idx_fact_customer ON dwh.fact_transactions(customer_key);
CREATE INDEX idx_fact_date ON dwh.fact_transactions(date_key);
CREATE INDEX idx_fact_location ON dwh.fact_transactions(location_key);
CREATE INDEX idx_household_id ON dim_customer(household_id);
