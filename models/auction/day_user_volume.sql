{{config(order_by='transaction_date, user_id', engine='SumMergeTree()')}}

SELECT toDate(valid_tr.transaction_time) AS financial_date,
valid_tr.user_id AS user_id,
valid_tr.amount_eur AS trading_volume
FROM {{ref('valid_transactions')}} AS valid_tr
WHERE valid_tr.transaction_type = 'trade'
