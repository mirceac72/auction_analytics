# Auction analytics

## Problem statement

An auction site collects data regarding transactions performed by its users and aims to obtain information like the trade volume per day per user, the total trade volume per day, the users
account balances and the inactive users.

## High level solution description

Data is collected into a [ClickHouse](https://clickhouse.com/) warehouse (ClickHouse is a resource efficient database that can also run a local machine).  

[dbt](https://www.getdbt.com/) is used in order to reduce the SQL boilerplate code and for the ability to chain SQL computations. The solution is described using only SQL statements. 

As a large number of transactions are expected to accumulate over time, the 
[incremental](https://docs.getdbt.com/best-practices/materializations/4-incremental-models)
materialisation of dbt will be used in order to process only the newly added transactions
from the last `dbt` run.

Transaction information is assumed to be streamed into ClickHouse from another system and
duplicate information is to be expected. The ClickHouse [ReplacingMergeTree](https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/replacingmergetree) engine will
be used on the source tables (the primary tables that receive information from the other system)
in order to remove these duplicates.  

The aggregate information that we aim to achieve involves summing transactions amounts over a period of time.
The ClickHouse [SumMergeTree]() engine is used in order to achive this effectively.

## Dbt commands

- dbt compile (Compile SQL statements including the ones from analyses section)
- dbt run
- dbt run --full-refresh (full processing for the incremental materialisations) 

## Steps

1. Define the source tables

Run the SQL statements in the folder `db_setup` in order to initialize the source tables in the staging area
(`auction_staging` schema). A simple tool like [clickhouse-migrations](https://github.com/VVVi/clickhouse-migrations) or complex tools like [Liquibase](https://www.liquibase.org/) can be used to manage these schema changes.

2. Load demo data (first batch)

The below command can be used in `clickhouse client` to initialize the source tables with demo data. 

```sql
INSERT INTO auction_staging.users FROM INFILE 'users.csv' FORMAT CSV;
INSERT INTO auction_staging.transactions FROM INFILE 'transactions_batch1.csv' FORMAT CSV;
```

The sample files `users.csv` and `transactions_batch1.csv` can be found into the `db_setup` folder. They contain 10 fictional users
and a couple of `deposit` and `trade` transactions performed on `2023-08-11` before 10 am.


Note: The following command can be used to remove the whole content of the `auction_staging.transactions`

```
TRUNCATE TABLE auction_staging.transactions;
```

In a production scenarion, the source tables can be filled by an Apache Beam pipeline or from 
a Kafka stream.

3. Compile dbt project

4. Run dbt project

In the first run, we ask to recompute the all models from scratch and specify the current time as being 11 am on 
`2023-08-11`.

```bash
dbt run --full-refresh --vars '{current_time:2023-08-11T11:00:00}'
```

5. Check the content of the tables that materialize the model

```sql
SELECT * FROM auction_analytics.transactions LIMIT 1000;
SELECT * FROM auction_analytics.valid_transactions LIMIT 1000;
SELECT * FROM auction_analytics.day_user_volume LIMIT 1000;
SELECT user_id, asset, sumMerge(amount) FROM auction_analytics.user_balance GROUP BY user_id, asset LIMIT 1000;
```

Table `day_user_volume` is empty because only the transactions until `2023-08-10` and inclusive are considered and 
our data set contains none. 

When selecting from `user_balance` table, we should keep in mind that the information for the table is
aggregated in the background so the query should take in account that aggregation may not be done yet.

6. Take the compiled `analysis` SQL statements and run them agains the ClickHouse `auction_analytics`
database.
