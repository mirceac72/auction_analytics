CREATE TABLE IF NOT EXISTS auction_staging.transactions(
    timestamp_str String,
    user_id String,
    asset String,
    transaction_type String,
    amount_str String,
    amount_eur_str String,
    created_at DateTime DEFAULT now()
) Engine = ReplacingMergeTree ORDER BY (timestamp_str, user_id, asset);