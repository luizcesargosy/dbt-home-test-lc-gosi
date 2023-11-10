{{ config(materialized='table') }}

-- A model that calculates the total transaction amount for each month over the last 12 months
-- 1. Calculate the percentage change in transaction totals from one month to the next
-- 2. calculate the top customer for each month by selecting the customer with the highest spending

-- Calculate monthly totals for transactions
WITH monthly_totals AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', DATE(t.transaction_date)), 'YYYY-MM-DD') AS transaction_month,
        t.customer_id,
        SUM(t.amount) AS total_amount
    FROM
        {{ ref('clean_transactions') }} t
    WHERE
        DATE(t.transaction_date) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '11 months')  -- Last 12 months
    GROUP BY
        transaction_month, t.customer_id
)
-- Rank customers by total_amount within each transaction_month
, ranked_customers AS (
    SELECT
        transaction_month,
        customer_id,
        total_amount,
        RANK() OVER (PARTITION BY transaction_month ORDER BY total_amount DESC) AS customer_rank
    FROM
        monthly_totals
)
-- Calculate the total amount for all customers within each transaction_month
, monthly_total_amount AS (
    SELECT
        transaction_month,
        SUM(total_amount) AS total_amount_all_customers
    FROM
        monthly_totals
    GROUP BY
        transaction_month
)
-- Select the top-ranked customers and calculate the percentage change in total_amount
SELECT
    mc.transaction_month,
    mc.customer_id,
    c.customer_name,
    ROUND(mc.total_amount::numeric, 2) as amount_spending_top_ranked_customer ,
    ROUND(mta.total_amount_all_customers::numeric, 2) as amount_spending_all_customers,
	ROUND(((mta.total_amount_all_customers::double precision - LAG(mta.total_amount_all_customers) OVER (ORDER BY mc.transaction_month)) /
        NULLIF(LAG(mta.total_amount_all_customers) OVER (ORDER BY mc.transaction_month), 0))::numeric,2) AS monthly_percent_diff_spending_top_and_all_customers
FROM
    ranked_customers mc
LEFT JOIN
     {{ ref('clean_customers') }} c
ON 
    c.customer_id = mc.customer_id 
JOIN
    monthly_total_amount mta
ON
    mc.transaction_month = mta.transaction_month
WHERE
    mc.customer_rank = 1
ORDER BY
    mc.transaction_month DESC