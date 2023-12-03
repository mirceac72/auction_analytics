/**
Create users table in the auction_staging schema. This table will store user data as it is received from
other systems without any transformation. 

User records may contain duplicates that will be removed at a later stage. Data is ordered by created_at to 
allow incremental processing of the data in the next stages.
*/

CREATE TABLE IF NOT EXISTS auction_staging.users (\
    user_id String,\
    full_name String,\
    country String,\
    created_at DateTime64(9) DEFAULT now64(9) \
) ENGINE = MergeTree() ORDER BY (created_at);