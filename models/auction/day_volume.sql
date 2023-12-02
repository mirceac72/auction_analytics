{{config(order_by='financial_date', engine='SumMergeTree()')}}

SELECT duv.financial_date AS financial_date, sum(duv.trading_volume) AS trading_volume
FROM {{ref('day_user_volume')}} AS duv
GROUP BY duv.financial_date