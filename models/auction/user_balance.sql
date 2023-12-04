/*
The current balance for every pair user asset. The amount of eur in the user's wallet is considered
a special asset named 'wallet_eur' and treated as any other asset.
It is assumed that every user transaction will reach the system within the maximum specified latency at
least once.
*/

{{config(materialized = 'incremental', 
    incremental_strategy='append',
    order_by = '(user_id, asset)', 
    engine = 'AggregatingMergeTree()',
    on_schema_change='fail'
    )}}

WITH 'wallet_eur' AS asset_eur,
transaction_colection AS (
    SELECT transaction_time AS updated_at,
    transaction_type AS transaction_type,
    user_id AS user_id,
    argMax(asset, received_at) AS asset,
    argMax(amount, received_at) AS amount,
    argMax(amount_eur, received_at) AS amount_eur
    FROM {{ref('valid_transactions')}}
    {% if is_incremental() %}
    WHERE addMinutes(transaction_time, {{var('max_latency')}}) > (SELECT maxMerge(updated_at) FROM {{this}})
    {% endif %}
    GROUP BY transaction_time, transaction_type, user_id
),
trade_transactions AS (
    SELECT * 
    FROM transaction_colection 
    WHERE transaction_type = 'trade'
),
asset_changes AS (
    SELECT user_id AS user_id,
    asset AS asset,
    amount AS amount,
    updated_at AS updated_at
    FROM trade_transactions
    UNION ALL
    SELECT user_id AS user_id,
    asset_eur AS asset,
    if(transaction_type = 'withdrawal', amount_eur, amount_eur) AS amount,
    updated_at AS updated_at
    FROM transaction_colection
)
SELECT
user_id AS user_id,
asset AS asset, 
sumState(amount) AS amount,
maxState(updated_at) AS updated_at
FROM asset_changes
GROUP BY user_id, asset
