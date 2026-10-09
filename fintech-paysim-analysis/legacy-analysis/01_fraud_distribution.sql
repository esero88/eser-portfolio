SELECT * FROM public.transactions LIMIT 10

SELECT COUNT(*) FROM transactions;


-- 1️⃣ Fraud Distribution (SQL)

SELECT "isFraud", COUNT(*) 
FROM transactions
GROUP BY "isFraud";

/* 
## Insight - Fraud Distribution

Fraud transactions are extremely rare compared to normal transactions.

Out of more than 6.3 million transactions, only around 8,200 are fraudulent.

This confirms a highly imbalanced dataset, where fraud cases represent a very small fraction of total activity.
*/

-- 2️⃣ Transaction Types

SELECT type, COUNT(*) 
FROM transactions
GROUP BY type
ORDER BY COUNT(*) DESC;

/* 
## Insight – Transaction Type Distribution

CASH_OUT and PAYMENT are the most common transaction types, followed by CASH_IN.

TRANSFER transactions are significantly fewer, and DEBIT is the least used type.

This shows that platform activity is heavily concentrated in a few transaction categories.
*/

-- 3️⃣ Fraud by Type

SELECT type, SUM("isFraud") 
FROM transactions
GROUP BY type;

/* 
## Insight – Fraud by Transaction Type

Fraud occurs only in CASH_OUT and TRANSFER transaction types.

No fraudulent activity is observed in CASH_IN, PAYMENT, or DEBIT transactions.

This indicates that fraud is strictly associated with money transfer and withdrawal operations.
*/

-- 4️⃣ Fraud Rate

SELECT 
    type,
    AVG("isFraud") AS fraud_rate
FROM transactions
GROUP BY type
ORDER BY fraud_rate DESC;

/* 
## Insight – Fraud Rate by Type

TRANSFER has the highest fraud rate (~0.77%), followed by CASH_OUT (~0.18%).

All other transaction types have a fraud rate of zero.

This clearly shows that fraud risk is highly concentrated in specific transaction types.
*/


-- 5️⃣ Average Amount

SELECT 
    type,
    AVG(amount) 
FROM transactions
GROUP BY type;

/* 
## Insight – Average Transaction Amount

TRANSFER transactions have by far the highest average amount (~910K), followed by CASH_OUT and CASH_IN (~170K).

PAYMENT and DEBIT transactions have significantly lower average values.

This suggests that high-value transactions are mostly associated with transfer-related activities, which also carry higher fraud risk.
*/

-- 6️⃣ Fraud vs Amount

SELECT 
    "isFraud",
    AVG(amount) AS avg_amount,
    MAX(amount) AS max_amount
FROM transactions
GROUP BY "isFraud";

/* 
## Insight – Fraud vs Transaction Amount

Fraudulent transactions have a slightly lower average amount compared to normal transactions.

However, both fraud and non-fraud transactions can reach very high maximum values (up to 1M).

This indicates that fraud is not solely dependent on transaction size, but rather on transaction type and behavior.
*/

-- 7️⃣ Balance Consistency Check

SELECT 
    COUNT(*) FILTER (WHERE "oldbalanceOrg" - amount != "newbalanceOrig") AS inconsistent_origin,
    COUNT(*) FILTER (WHERE "oldbalanceDest" + amount != "newbalanceDest") AS inconsistent_destination
FROM transactions;

/* 
## Insight – Balance Inconsistency

A very large number of transactions show inconsistencies in account balances.

Over 5 million transactions have mismatches in origin balance, and over 4 million in destination balance.

This suggests that balance inconsistency is common in the dataset and may be related to how the data is generated or simulated.

Therefore, this feature should be used carefully when detecting fraud.
*/

-- 8️⃣ Fraud Over Time (Step)

SELECT 
    step,
    COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_count
FROM transactions
GROUP BY step
ORDER BY step;

/* 
## Insight – Fraud Over Time

Fraud transactions are distributed across different time steps without a clear consistent pattern.

Fraud counts fluctuate but remain relatively low at each step.

This suggests that fraud does not depend strongly on time alone and requires additional features for detection.
*/

/* 
## Insight – Overall

Fraud is highly concentrated in specific transaction types (TRANSFER and CASH_OUT) and does not occur in others.

Transaction type is the strongest indicator of fraud, while amount and time alone are not sufficient predictors.

The dataset is highly imbalanced, and some features like balance inconsistencies are widespread, requiring careful interpretation.

Effective fraud detection should combine transaction type with behavioral patterns rather than relying on a single variable.
*/