WITH transactions AS (
    SELECT parseDateTime64BestEffortOrNull(tr_stg.timestamp_str) AS transaction_time,
    toInt64OrNull(tr_stg.user_id) AS user_id,
    lower(tr_stg.asset) AS asset,
    lowerUTF8(tr_stg.transaction_type) AS transaction_type,
    toDecimal64OrNull(tr_stg.amount_str, 4) AS amount,
    toDecimal64OrNull(tr_stg.amount_eur_str, 4) AS amount_eur
    FROM {{source('auction_staging', 'transactions')}} AS tr_stg
)
SELECT *
FROM transactions