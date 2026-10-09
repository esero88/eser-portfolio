/* =========================
   10. DATA MART: FINANCIAL SUMMARY
========================= */

--A business-oriented data mart was created to provide aggregated transaction metrics
--and fraud KPIs for analytical and reporting purposes.

CREATE SCHEMA IF NOT EXISTS datamart;

DROP TABLE IF EXISTS datamart.financial_summary;

CREATE TABLE datamart.financial_summary AS
SELECT
    --Synthetic timestamp generated from step (hour-based simulation)
    (DATE '2020-01-01' + (d.step || ' hours')::interval) AS transaction_timestamp,

    --Time breakdown for flexible analysis
    d.week,
    d.day,
    d.hour,

    --Business-friendly transaction type
    t.type_name AS transaction_type,

    --Core transaction metrics
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount,
    AVG(f.amount) AS avg_amount,

    --Fraud metrics
    SUM(f.is_fraud) AS fraud_transactions,
    SUM(f.is_flagged_fraud) AS flagged_transactions,

    --Fraud rate calculation (safe division)
    CASE 
        WHEN COUNT(*) = 0 THEN 0
        ELSE SUM(f.is_fraud)::FLOAT / COUNT(*)
    END AS fraud_rate

FROM dwh.fact_transactions f
JOIN dwh.dim_time d 
    ON f.step = d.step
JOIN dwh.dim_transaction_type t 
    ON f.type_id = t.type_id

GROUP BY
    (DATE '2020-01-01' + (d.step || ' hours')::interval),
    d.week,
    d.day,
    d.hour,
    t.type_name;

/* =========================
   11. DATA VALIDATION
========================= */

--Basic validation checks were performed to ensure the data mart was created correctly.

SELECT COUNT(*) AS total_rows
FROM datamart.financial_summary;

SELECT *
FROM datamart.financial_summary
LIMIT 20;


/* =========================
   12. PERFORMANCE OPTIMIZATION
========================= */

--Indexes can be added to improve query performance for BI tools.


CREATE INDEX idx_datamart_date
ON datamart.financial_summary(transaction_date);

CREATE INDEX idx_datamart_type
ON datamart.financial_summary(transaction_type);