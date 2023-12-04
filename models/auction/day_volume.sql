/*
A table with the total trading volume per day. It is computed as new days become available in the 
day_user_volume table.
*/

{{config(materialized = 'incremental', incremental_strategy='append', order_by='financial_date', engine='MergeTree()')}}

SELECT duv.financial_date AS financial_date, sum(duv.trading_volume) AS trading_volume
FROM {{ref('day_user_volume')}} AS duv
{% if is_incremental() %}
WHERE duv.financial_date > (SELECT max(financial_date) FROM {{this}})
{% endif %}
GROUP BY duv.financial_date