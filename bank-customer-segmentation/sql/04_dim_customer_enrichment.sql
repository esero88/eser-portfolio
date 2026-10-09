-- =====================================================
-- DIM_CUSTOMER ENRICHMENT
-- Household, Marital Status & Account Status
-- =====================================================

--------------------------------------------------------
-- 1. HOUSEHOLD CREATION
--------------------------------------------------------

ALTER TABLE dwh.dim_customer 
ADD COLUMN IF NOT EXISTS household_id INT;

UPDATE dwh.dim_customer
SET household_id = customer_key / 3;


--------------------------------------------------------
-- 2. MARITAL STATUS DERIVATION
--------------------------------------------------------

ALTER TABLE dwh.dim_customer 
ADD COLUMN IF NOT EXISTS marital_status_derived TEXT;

WITH household_gender AS (
    SELECT 
        household_id,
        COUNT(DISTINCT customer_gender) AS gender_count
    FROM dwh.dim_customer
    GROUP BY household_id
)

UPDATE dwh.dim_customer c
SET marital_status_derived = CASE 
    WHEN c.household_id IS NOT NULL
         AND EXTRACT(YEAR FROM AGE(c.customer_dob)) BETWEEN 25 AND 60
         AND hg.gender_count > 1
    THEN 'Married'
    ELSE 'Single'
END
FROM household_gender hg
WHERE c.household_id = hg.household_id;


--------------------------------------------------------
-- 3. ACCOUNT STATUS DERIVATION (RECENCY BASED)
--------------------------------------------------------

ALTER TABLE dwh.dim_customer 
ADD COLUMN IF NOT EXISTS account_status TEXT;

-- (Opsiyonel ama iyi practice)
UPDATE dwh.dim_customer
SET account_status = NULL;

WITH last_tx AS (
    SELECT 
        customer_key,
        MAX(date_key) AS last_tx_date
    FROM dwh.fact_transactions
    GROUP BY customer_key
),
max_date AS (
    SELECT MAX(date_key) AS max_dt
    FROM dwh.fact_transactions
)

UPDATE dwh.dim_customer c
SET account_status = CASE 
    WHEN (
        TO_DATE(md.max_dt::text, 'YYYYMMDD') 
        - TO_DATE(lt.last_tx_date::text, 'YYYYMMDD')
    ) <= 7 THEN 'Active'

    WHEN (
        TO_DATE(md.max_dt::text, 'YYYYMMDD') 
        - TO_DATE(lt.last_tx_date::text, 'YYYYMMDD')
    ) <= 30 THEN 'Suspended'

    ELSE 'Closed'
END
FROM last_tx lt, max_date md
WHERE c.customer_key = lt.customer_key;


--------------------------------------------------------
-- 4. VALIDATION
--------------------------------------------------------

-- Sample check
SELECT * 
FROM dwh.dim_customer
LIMIT 10;

-- Marital status distribution
SELECT 
    marital_status_derived,
    COUNT(*) AS customer_count
FROM dwh.dim_customer
GROUP BY marital_status_derived;

-- Account status distribution
SELECT 
    account_status,
    COUNT(*) AS customer_count
FROM dwh.dim_customer
GROUP BY account_status;

-- Dataset date range
SELECT 
    MAX(date_key) AS max_date,
    MIN(date_key) AS min_date
FROM dwh.fact_transactions;
