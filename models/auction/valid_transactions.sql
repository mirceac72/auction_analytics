SELECT *
FROM {{ref('transactions')}}
WHERE transaction_time IS NOT NULL AND
user_id IS NOT NULL AND
amount IS NOT NULL AND
amount_eur IS NOT NULL AND
amount > 0 AND amount_eur > 0 AND
transaction_type IN ('trade', 'deposit', 'withdrawal')
