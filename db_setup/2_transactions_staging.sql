/**
Create transactions table in the auction_staging schema. This table will store transaction data as it is received from
other systems without any transformation.

Transaction records may contain duplicates that will be removed at a later stage. Data is ordered by created_at to 
allow incremental processing of the data in the next stages.
*/

CREATE TABLE IF NOT EXISTS auction_staging.transactions(
    timestamp_str String,
    user_id String,
    asset String,
    transaction_type String,
    amount_str String,
    amount_eur_str String,
    created_at DateTime64(9) DEFAULT now64(9)
) Engine = MergeTree() ORDER BY (created_at);