/**
A table with valid transactions (that pass the validation rules).
Duplicates are removed in the background by using the ReplacingMergeTree engine.
*/

{{config(materialized = 'incremental', 
    incremental_strategy='append',
    order_by = '(transaction_time, transaction_type, user_id)', 
    engine = 'ReplacingMergeTree(received_at)', 
    unique_key = '(transaction_time, transaction_type, user_id)',
    on_schema_change='fail'
    )}}

SELECT assumeNotNull(transaction_time) AS transaction_time,
assumeNotNull(transaction_type) AS transaction_type,
assumeNotNull(user_id) AS user_id,
assumeNotNull(amount_eur) AS amount_eur,
asset AS asset,
amount AS amount,
received_at AS received_at
FROM {{ref('transactions')}}
WHERE transaction_time IS NOT NULL AND
transaction_type IN ('trade', 'deposit', 'withdrawal') AND
user_id IS NOT NULL AND
amount_eur IS NOT NULL AND
((amount IS NOT NULL AND asset IS NOT NULL) OR transaction_type != 'trade')

{% if is_incremental() %}

-- this filter will only be applied on an incremental run
AND received_at > (SELECT max(received_at) FROM {{this}})

{% endif %}
