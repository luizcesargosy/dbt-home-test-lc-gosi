{{ config(materialized='table') }}

-- A model that consolidates relevant customer information with their transactions
-- 1. Total transactions made by each customer
-- 2. Their average monthly spending
-- 3. The average customer spending interval, representing the average number of days it takes for the customer to perform a transaction

WITH DateDifferences AS (
    SELECT
        t.customer_id,
        t.transaction_date,
        LAG(t.transaction_date) OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date) AS prev_transaction_date,-- Retrieve the previous transaction date
        t.amount,
        LAG(t.amount) OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date) AS prev_transaction_amount -- Retrieve the previous transaction amount
    FROM
        {{ ref('clean_transactions') }} t
), 
-- Calculate monthly sums of transaction amounts for each customer. It can have 2 transactions for the same month. Necessary Sum to do monthly avg
MonthlySums AS (
    SELECT
        c.customer_id,
        DATE_TRUNC('month', t.transaction_date) AS transaction_month,
        SUM(t.amount) AS monthly_sum
    FROM
        {{ ref('clean_customers') }} c
    LEFT JOIN
        DateDifferences t
    ON
        c.customer_id = t.customer_id
    GROUP BY
        c.customer_id, transaction_month
)
-- Consolidate customer information with transaction data
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(distinct t.transaction_date) AS total_transactions, -- Count the total number of distinct transaction dates for each customer
    ROUND(AVG(ms.monthly_sum)::numeric, 2) AS avg_monthly_amount_spending, -- Calculate the average monthly spending for each customer based on monthly sums
    ROUND(AVG((transaction_date - prev_transaction_date)::int)::numeric, 2) AS avg_days_interval_transactions -- Calculate the average customer spending interval as the average number of days between transactions
FROM
     {{ ref('clean_customers') }} c
LEFT JOIN
    DateDifferences t
ON
    c.customer_id = t.customer_id
LEFT JOIN
    MonthlySums ms
ON
    c.customer_id = ms.customer_id
GROUP BY
    c.customer_id, c.customer_name
ORDER BY
    total_transactions DESC, avg_monthly_amount_spending DESC