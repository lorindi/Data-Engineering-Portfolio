-- Staging for transactions. Takes the newest row of each transaction from Bronze and makes the hash keys for the transaction, the account and the link.
with newest_transaction_rows_from_bronze as (
    select
        trim(TRANS_ID)          as TRANS_ID,
        trim(ACCOUNT_ID)        as ACCOUNT_ID,
        DATE,
        TYPE,
        OPERATION,
        AMOUNT,
        BALANCE,
        K_SYMBOL,
        BANK,
        PARTNER_ACCOUNT,
        SOURCE_FILE_NAME        as RECORD_SOURCE,
        current_timestamp()     as LOAD_DATE
    from {{ source('bronze', 'berka_trans_raw') }}
    where TRANS_ID is not null
      and ACCOUNT_ID is not null
    qualify row_number() over (
        partition by trim(TRANS_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) = 1
)

select
    {{ automate_dv.hash(columns='TRANS_ID', alias='TRANSACTION_HASH_KEY') }},
    {{ automate_dv.hash(columns='ACCOUNT_ID', alias='ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['TRANS_ID', 'ACCOUNT_ID'], alias='TRANSACTION_ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['DATE', 'TYPE', 'OPERATION', 'AMOUNT', 'BALANCE', 'K_SYMBOL', 'BANK', 'PARTNER_ACCOUNT'], alias='HASH_DIFF', is_hashdiff=true) }},
    TRANS_ID,
    ACCOUNT_ID,
    DATE,
    TYPE,
    OPERATION,
    AMOUNT,
    BALANCE,
    K_SYMBOL,
    BANK,
    PARTNER_ACCOUNT,
    LOAD_DATE,
    RECORD_SOURCE
from newest_transaction_rows_from_bronze
