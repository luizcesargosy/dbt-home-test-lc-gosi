    {{ config(materialized='table') }}

    SELECT
        c.customer_id,
        c.name as customer_name,
        c.date_of_birth,
        c.joined_date
    FROM
        {{ ref('customers') }} c
    ORDER BY 
        c.customer_id DESC