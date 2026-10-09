-- =====================================================
-- FACT_TRANSACTIONS ENRICHMENT
-- Transaction Type Classification
-- =====================================================

--------------------------------------------------------
-- 1. COLUMN CREATION
--------------------------------------------------------

ALTER TABLE dwh.fact_transactions
ADD COLUMN IF NOT EXISTS transaction_type TEXT;


--------------------------------------------------------
-- 2. RESET PREVIOUS VALUES (IDEMPOTENT)
--------------------------------------------------------

UPDATE dwh.fact_transactions
SET transaction_type = NULL;


--------------------------------------------------------
-- 3. RECURRING TRANSACTION DETECTION
-- Identify repeated transaction amounts per customer
--------------------------------------------------------

WITH recurring AS (
    SELECT 
        customer_key,
        transaction_amount,
        COUNT(*) AS cnt
    FROM dwh.fact_transactions
    GROUP BY customer_key, transaction_amount
    HAVING COUNT(*) >= 2
),

--------------------------------------------------------
-- 4. RANK RECURRING TRANSACTIONS
-- Highest recurring amount assumed as loan candidate
--------------------------------------------------------

ranked AS (
    SELECT 
        customer_key,
        transaction_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_key
            ORDER BY transaction_amount DESC
        ) AS rn
    FROM recurring
)

--------------------------------------------------------
-- 5. ASSIGN LOAN & BILL PAYMENTS
--------------------------------------------------------

UPDATE dwh.fact_transactions f
SET transaction_type = CASE 

    -- Loan Payments:
    -- Highest recurring amount within a realistic range
    WHEN r.rn = 1 
         AND f.transaction_amount BETWEEN 500 AND 5000
    THEN 'Loan Payment'

    -- Bill Payments:
    -- Smaller recurring transactions (utilities, subscriptions)
    WHEN rec.customer_key IS NOT NULL
         AND f.transaction_amount < 500
    THEN 'Bill Payment'

END

FROM recurring rec
LEFT JOIN ranked r
    ON r.customer_key = rec.customer_key
   AND r.transaction_amount = rec.transaction_amount

WHERE f.customer_key = rec.customer_key
  AND f.transaction_amount = rec.transaction_amount;


--------------------------------------------------------
-- 6. ASSIGN NON-RECURRING TRANSACTIONS
-- Remaining transactions classified by amount distribution
--------------------------------------------------------

UPDATE dwh.fact_transactions
SET transaction_type = CASE
    WHEN transaction_amount < 1500 THEN 'Purchase'
    ELSE 'Transfer'
END
WHERE transaction_type IS NULL;


--------------------------------------------------------
-- 7. VALIDATION
--------------------------------------------------------

-- Distribution check
SELECT 
    transaction_type, 
    COUNT(*) AS transaction_count
FROM dwh.fact_transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;