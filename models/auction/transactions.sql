/**
A table with transactions where the conversion to ClickHouse types is attempted.
Null value are used for the fields that cannot be converted.
The table can still contain duplicates that will be removed at a later stage.
The table is ordered by received_at to allow incremental processing of the data in the next stages.
*/

{{config(materialized = 'incremental', engine = 'MergeTree()', order_by = 'received_at', incremental_strategy='append')}}

WITH transactions AS (
    SELECT parseDateTime64BestEffortOrNull(tr_stg.timestamp_str) AS transaction_time,
    toUUIDOrNull(tr_stg.user_id) AS user_id,
    lower(tr_stg.asset) AS asset,
    lowerUTF8(tr_stg.transaction_type) AS transaction_type,
    toDecimal64OrNull(tr_stg.amount_str, 4) AS amount,
    toDecimal64OrNull(tr_stg.amount_eur_str, 4) AS amount_eur,
    tr_stg.created_at AS received_at
    FROM {{source('auction_staging', 'transactions')}} AS tr_stg
)
SELECT *
FROM transactions


{% if is_incremental() %}

-- this filter will only be applied on an incremental run
WHERE received_at > (SELECT max(received_at) FROM {{this}})

{% endif %}
