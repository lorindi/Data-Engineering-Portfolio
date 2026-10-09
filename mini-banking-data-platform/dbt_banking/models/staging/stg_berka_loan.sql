-- Staging for loans. Takes the newest row of each loan from Bronze and makes the hash keys for the loan, the account and the link.


-- Reads from Bronze (source: bronze.berka_loan_raw).
-- Runs first. hub_loan, sat_loan_details and link_loan_account read from this view.

with newest_loan_rows_from_bronze as (
    select
        trim(LOAN_ID) as LOAN_ID,
        trim(ACCOUNT_ID) as ACCOUNT_ID,
        DATE,
        AMOUNT,
        DURATION,
        PAYMENTS,
        STATUS,
        SOURCE_FILE_NAME as RECORD_SOURCE,
        current_timestamp() as LOAD_DATE
    from {{source('bronze', 'berka_loan_raw')}}
    where LOAN_ID is not null
        and ACCOUNT_ID is not null
    qualify row_number() over (
        partition by trim(LOAN_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) =1
)

select
    {{ automate_dv.hash(columns='LOAN_ID', alias='LOAN_HASH_KEY') }},
    {{ automate_dv.hash(columns='ACCOUNT_ID', alias='ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['LOAN_ID', 'ACCOUNT_ID'], alias='LOAN_ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['DATE', 'AMOUNT', 'DURATION', 'PAYMENTS', 'STATUS'], alias='HASH_DIFF', is_hashdiff=true) }},
    LOAN_ID,
    ACCOUNT_ID,
    DATE,
    AMOUNT,
    DURATION,
    PAYMENTS,
    STATUS,
    LOAD_DATE,
    RECORD_SOURCE
from newest_loan_rows_from_bronze

