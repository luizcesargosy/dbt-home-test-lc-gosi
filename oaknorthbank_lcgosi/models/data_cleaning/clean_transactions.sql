    {{ config(materialized='table') }}

    SELECT
    	t.transaction_id,
        t.customer_id,
        to_date(t.transaction_date, 'YYYY-MM-DD') AS transaction_date, ---- Convert transaction_date to date format
        t.amount
    FROM
        {{ ref('transactions') }} t
    WHERE
            t.transaction_date IS NOT NULL
        AND t.customer_id IS NOT NULL
        AND t.transaction_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}' -- Filter dates in the appropriate format "YYYY-MM-DD"
        AND EXTRACT(YEAR FROM t.transaction_date::DATE) <= EXTRACT(YEAR FROM CURRENT_DATE)  -- Filter dates from the current year
    GROUP BY
    	t.transaction_id,
        t.customer_id,
        to_date(t.transaction_date, 'YYYY-MM-DD'),
        t.amount
    ORDER BY
        t.transaction_id DESC