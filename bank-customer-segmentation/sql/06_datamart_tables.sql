/*
========================================================
Data Mart: Customer Summary
========================================================

Purpose:
Creates a customer-level analytical summary table
for behavioral analysis, segmentation, and BI reporting.

Grain:
1 row per customer

Business Logic:
- Aggregates transaction metrics at customer level
- Calculates customer activity duration
- Summarizes transaction behavior patterns
- Supports future RFM and segmentation analysis

Main Metrics:
- Total transaction volume
- Average transaction amount
- Transaction type distributions
- Customer activity duration
- Average account balance

Source Tables:
- dwh.fact_transactions
- dwh.dim_customer
- dwh.dim_date
- dwh.dim_location

========================================================
*/

CREATE TABLE datamart.mart_customer_summary AS
SELECT
    dc.customer_id,
    COUNT(ft.transaction_key) AS total_transactions,
    SUM(ft.transaction_amount) AS total_amount,
    AVG(ft.transaction_amount) AS avg_transaction_amount,
    MAX(ft.transaction_amount) AS max_transaction_amount,
    MIN(ft.transaction_amount) AS min_transaction_amount,
    COUNT(DISTINCT dd.date) AS active_days,
    MIN(dd.date) AS first_transaction_date,
    MAX(dd.date) AS last_transaction_date,
    MAX(dd.date) - MIN(dd.date) AS customer_tenure_days,
    SUM(CASE WHEN ft.transaction_type = 'Purchase' THEN 1 ELSE 0 END) AS purchase_count,
    SUM(CASE WHEN ft.transaction_type = 'Transfer' THEN 1 ELSE 0 END) AS transfer_count,
    SUM(CASE WHEN ft.transaction_type = 'Bill Payment' THEN 1 ELSE 0 END) AS bill_payment_count,
    SUM(CASE WHEN ft.transaction_type = 'Loan Payment' THEN 1 ELSE 0 END) AS loan_payment_count,
    dc.account_status,
    dc.customer_gender,
    dc.marital_status_derived,
    dl.customer_location,
    AVG(ft.account_balance) AS avg_account_balance
FROM dwh.fact_transactions ft
JOIN dwh.dim_customer dc
    ON ft.customer_key = dc.customer_key
JOIN dwh.dim_date dd
    ON ft.date_key = dd.date_key
JOIN dwh.dim_location dl
    ON ft.location_key = dl.location_key
GROUP BY
    dc.customer_id,
    dc.account_status,
    dc.customer_gender,
    dc.marital_status_derived,
    dl.customer_location;

SELECT * 
FROM datamart.mart_customer_summary
LIMIT 5;

/*
========================================================
Data Mart: Financial Summary
========================================================

Purpose:
Creates a time-based financial aggregation table
for KPI tracking, trend analysis, and BI reporting.

Grain:
1 row per date

Business Logic:
- Aggregates daily transaction activity
- Summarizes transaction volumes and amounts
- Tracks behavioral transaction distributions
- Enables financial trend analysis

Main Metrics:
- Total transaction count
- Total transaction volume
- Average transaction amount
- Daily transaction behavior distribution
- Active customer count

Source Tables:
- dwh.fact_transactions
- dwh.dim_date

========================================================
*/

CREATE TABLE datamart.mart_financial_summary AS
SELECT
    dd.date,
    dd.year,
    dd.month,
    dd.day,
    COUNT(ft.transaction_key) AS total_transactions,
    COUNT(DISTINCT ft.customer_key) AS active_customers,
    SUM(ft.transaction_amount) AS total_transaction_amount,
    AVG(ft.transaction_amount) AS avg_transaction_amount,
    MAX(ft.transaction_amount) AS max_transaction_amount,
    MIN(ft.transaction_amount) AS min_transaction_amount,
    SUM(CASE WHEN ft.transaction_type = 'Purchase' THEN 1 ELSE 0 END) AS purchase_count,
    SUM(CASE WHEN ft.transaction_type = 'Transfer' THEN 1 ELSE 0 END) AS transfer_count,
    SUM(CASE WHEN ft.transaction_type = 'Bill Payment' THEN 1 ELSE 0 END) AS bill_payment_count,
    SUM(CASE WHEN ft.transaction_type = 'Loan Payment' THEN 1 ELSE 0 END) AS loan_payment_count
FROM dwh.fact_transactions ft
JOIN dwh.dim_date dd
    ON ft.date_key = dd.date_key
GROUP BY
    dd.date,
    dd.year,
    dd.month,
    dd.day;

SELECT *
FROM datamart.mart_financial_summary

/*
========================================================
Data Mart: Customer Behavior
========================================================

Purpose:
Creates a behavioral segmentation layer for
customer analytics and BI reporting.

Grain:
1 row per customer

Business Logic:
- Segments customers based on transaction behavior
- Identifies dominant transaction patterns
- Classifies customer value and activity levels
- Supports future RFM and clustering analysis

Main Features:
- Dominant transaction behavior
- Customer activity segmentation
- Value-based customer classification
- Transaction frequency analysis

Source Tables:
- datamart.mart_customer_summary

========================================================
*/

CREATE TABLE datamart.mart_customer_behavior AS
SELECT
    customer_id,
    total_transactions,
    total_amount,
    avg_transaction_amount,
    active_days,
    customer_tenure_days,
    purchase_count,
    transfer_count,
    bill_payment_count,
    loan_payment_count,
    account_status,
    customer_gender,
    marital_status_derived,
    customer_location,
    avg_account_balance,
    CASE
        WHEN purchase_count >= transfer_count
             AND purchase_count >= bill_payment_count
             AND purchase_count >= loan_payment_count
        THEN 'Purchase Focused'
        WHEN transfer_count >= purchase_count
             AND transfer_count >= bill_payment_count
             AND transfer_count >= loan_payment_count
        THEN 'Transfer Focused'
        WHEN bill_payment_count >= purchase_count
             AND bill_payment_count >= transfer_count
             AND bill_payment_count >= loan_payment_count
        THEN 'Bill Payment Focused'
        ELSE 'Loan Payment Focused'
    END AS dominant_behavior,
    CASE
        WHEN total_amount >= 100000 THEN 'High Value'
        WHEN total_amount >= 30000 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS value_segment,
    CASE
        WHEN total_transactions >= 50 THEN 'Highly Active'
        WHEN total_transactions >= 20 THEN 'Moderately Active'
        ELSE 'Low Activity'
    END AS activity_segment
FROM datamart.mart_customer_summary;

SELECT *
FROM datamart.mart_customer_behavior
LIMIT 10


/*
========================================================
Data Mart: RFM Segmentation
========================================================

Purpose:
Creates an RFM-based customer segmentation layer
for customer analytics, retention analysis, and BI reporting.

Grain:
1 row per customer

RFM Metrics:
- Recency  : How recently the customer transacted
- Frequency: How often the customer transacts
- Monetary : Total transaction value

Business Value:
- Customer loyalty analysis
- Customer retention monitoring
- High-value customer identification
- Dormant customer detection
- Marketing and CRM segmentation

Source Tables:
- datamart.mart_customer_summary

========================================================
*/

CREATE TABLE datamart.mart_rfm_segmentation AS
WITH rfm_base AS (
    SELECT
        customer_id,
        CURRENT_DATE - last_transaction_date AS recency,
        total_transactions AS frequency,
        total_amount AS monetary
    FROM datamart.mart_customer_summary
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency ASC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
    FROM rfm_base
)
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(
        recency_score,
        frequency_score,
        monetary_score
    ) AS rfm_score,
    CASE
        WHEN recency_score >= 4
         AND frequency_score >= 4
         AND monetary_score >= 4
        THEN 'Champions'
        WHEN recency_score >= 3
         AND frequency_score >= 3
         AND monetary_score >= 3
        THEN 'Loyal Customers'
        WHEN recency_score >= 3
         AND frequency_score <= 2
        THEN 'Potential Loyalists'
        WHEN recency_score <= 2
         AND frequency_score >= 3
        THEN 'At Risk'
        ELSE 'Dormant'
    END AS customer_segment
FROM rfm_scores;

SELECT *
FROM datamart.mart_rfm_segmentation
LIMIT 10