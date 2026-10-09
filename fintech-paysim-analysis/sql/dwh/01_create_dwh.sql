/* =========================
   1. STAGING (ACCOUNT)
========================= */

--All unique accounts participating in transactions are extracted into a single list.

CREATE TEMP TABLE tmp_accounts AS
SELECT "nameOrig" AS account_id FROM public.transactions
UNION
SELECT "nameDest" FROM public.transactions;


/* =========================
   2. DIMENSION: ACCOUNT
========================= */

--Unique accounts were transformed into a structured dimension table with business classification (customer vs merchant).

DROP TABLE IF EXISTS dwh.dim_account;

CREATE TABLE dwh.dim_account (
    account_id VARCHAR(50),
    account_type VARCHAR(10)
);

INSERT INTO dwh.dim_account (account_id, account_type)
SELECT account_id,
       CASE 
           WHEN account_id LIKE 'C%' THEN 'Customer'
           ELSE 'Merchant'
       END
FROM tmp_accounts;

ALTER TABLE dwh.dim_account
ADD PRIMARY KEY (account_id);


/* =========================
   3. DIMENSION: TRANSACTION TYPE
========================= */

--Transaction types were extracted and deduplicated into a separate dimension table to standardize and optimize analytical queries.

DROP TABLE IF EXISTS dwh.dim_transaction_type;

CREATE TABLE dwh.dim_transaction_type (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) UNIQUE
);

INSERT INTO dwh.dim_transaction_type (type_name)
SELECT DISTINCT type
FROM public.transactions;


/* =========================
   4. DIMENSION: TIME
========================= */

--Transaction step values were transformed into meaningful time attributes (hour, day, week) to enable time-based analysis.

DROP TABLE IF EXISTS dwh.dim_time;

CREATE TABLE dwh.dim_time (
    step INT PRIMARY KEY,
    hour INT,
    day INT,
    week INT
);

INSERT INTO dwh.dim_time (step, hour, day, week)
SELECT DISTINCT 
    step,
    step % 24 AS hour,
    (step / 24) + 1 AS day,
    (step / (24*7)) + 1 AS week
FROM public.transactions;


/* =========================
   5. FACT: TRANSACTIONS
========================= */

--Transaction data was transformed into a fact table by linking each transaction to its corresponding dimensions using surrogate keys.

DROP TABLE IF EXISTS dwh.fact_transactions;

CREATE TABLE dwh.fact_transactions (
    transaction_id BIGSERIAL,
    step INT,
    amount NUMERIC,
    is_fraud INT,
    is_flagged_fraud INT,
    type_id INT,
    origin_account_id VARCHAR(50),
    destination_account_id VARCHAR(50)
);

INSERT INTO dwh.fact_transactions (
    step,
    amount,
    is_fraud,
    is_flagged_fraud,
    type_id,
    origin_account_id,
    destination_account_id
)
SELECT 
    t.step,
    t.amount,
    t."isFraud",
    t."isFlaggedFraud",
    d.type_id,
    t."nameOrig",
    t."nameDest"
FROM public.transactions t
JOIN dwh.dim_transaction_type d
ON t.type = d.type_name;


/* =========================
   6. INDEXES
========================= */

--Indexes were created on foreign key columns to optimize join performance between fact and dimension tables.

CREATE INDEX idx_fact_origin 
ON dwh.fact_transactions(origin_account_id);

CREATE INDEX idx_fact_dest 
ON dwh.fact_transactions(destination_account_id);


/* =========================
   7. FOREIGN KEYS
========================= */

--Foreign key constraints were added to enforce referential integrity between the fact table and dimension tables.

ALTER TABLE dwh.fact_transactions
ADD CONSTRAINT fk_origin
FOREIGN KEY (origin_account_id)
REFERENCES dwh.dim_account(account_id);

ALTER TABLE dwh.fact_transactions
ADD CONSTRAINT fk_dest
FOREIGN KEY (destination_account_id)
REFERENCES dwh.dim_account(account_id);

ALTER TABLE dwh.fact_transactions
ADD CONSTRAINT fk_type
FOREIGN KEY (type_id)
REFERENCES dwh.dim_transaction_type(type_id);

ALTER TABLE dwh.fact_transactions
ADD CONSTRAINT fk_time
FOREIGN KEY (step)
REFERENCES dwh.dim_time(step);


/* =========================
   8. DATA QUALITY CHECK
========================= */

--Data quality checks were performed to ensure all fact records correctly map to their corresponding dimension tables.

-- Origin kontrol
SELECT COUNT(*) AS missing_origin
FROM dwh.fact_transactions f
LEFT JOIN dwh.dim_account a
ON f.origin_account_id = a.account_id
WHERE a.account_id IS NULL;

-- Destination kontrol
SELECT COUNT(*) AS missing_dest
FROM dwh.fact_transactions f
LEFT JOIN dwh.dim_account a
ON f.destination_account_id = a.account_id
WHERE a.account_id IS NULL;

-- Type kontrol
SELECT COUNT(*) AS missing_type
FROM dwh.fact_transactions f
LEFT JOIN dwh.dim_transaction_type d
ON f.type_id = d.type_id
WHERE d.type_id IS NULL;

-- Time kontrol
SELECT COUNT(*) AS missing_time
FROM dwh.fact_transactions f
LEFT JOIN dwh.dim_time t
ON f.step = t.step
WHERE t.step IS NULL;


/* =========================
   9. PERFORMANCE OPTIMIZATION
========================= */

--Table statistics were updated to help the query optimizer generate efficient execution plans.

ANALYZE dwh.dim_account;
ANALYZE dwh.dim_transaction_type;
ANALYZE dwh.dim_time;
ANALYZE dwh.fact_transactions;