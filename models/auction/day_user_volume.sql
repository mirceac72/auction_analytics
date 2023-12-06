/*
A table with the total trading volume per user per day. It is computed once per day and it should be called
when the entire information for the previous day is available.
*/
 

{{config(materialized = 'incremental', order_by='financial_date, user_id', engine='SummingMergeTree()')}}

SELECT toDate(valid_tr.transaction_time) AS financial_date,
valid_tr.user_id AS user_id,
argMax(valid_tr.amount_eur, received_at) AS trading_volume -- remove potential duplicates by keeping the latest received_at
FROM {{ref('valid_transactions')}} AS valid_tr
WHERE valid_tr.transaction_type = 'trade'
AND financial_date <= toDate(subtractMinutes(parseDateTimeBestEffortOrNull('{{var('current_time')}}'), {{var('max_latency')}})) - 1
{% if is_incremental() %}
AND financial_date > (SELECT max(financial_date) FROM {{this}})
{% endif %}
GROUP BY valid_tr.transaction_time, valid_tr.transaction_type, valid_tr.user_id -- group in order to remove potetial duplicates
