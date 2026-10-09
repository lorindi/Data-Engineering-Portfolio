-- Staging for permanent orders. Takes the newest row of each order from Bronze and makes the hash keys for the order, the account and the link.
with newest_order_rows_from_bronze as (
    select
        trim(ORDER_ID)          as ORDER_ID,
        trim(ACCOUNT_ID)        as ACCOUNT_ID,
        BANK_TO,
        ACCOUNT_TO,
        AMOUNT,
        K_SYMBOL,
        SOURCE_FILE_NAME        as RECORD_SOURCE,
        current_timestamp()     as LOAD_DATE
    from {{ source('bronze', 'berka_order_raw') }}
    where ORDER_ID is not null
      and ACCOUNT_ID is not null
    qualify row_number() over (
        partition by trim(ORDER_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) = 1
)

select
    {{ automate_dv.hash(columns='ORDER_ID', alias='ORDER_HASH_KEY') }},
    {{ automate_dv.hash(columns='ACCOUNT_ID', alias='ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['ORDER_ID', 'ACCOUNT_ID'], alias='ORDER_ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['BANK_TO', 'ACCOUNT_TO', 'AMOUNT', 'K_SYMBOL'], alias='HASH_DIFF', is_hashdiff=true) }},
    ORDER_ID,
    ACCOUNT_ID,
    BANK_TO,
    ACCOUNT_TO,
    AMOUNT,
    K_SYMBOL,
    LOAD_DATE,
    RECORD_SOURCE
from newest_order_rows_from_bronze
