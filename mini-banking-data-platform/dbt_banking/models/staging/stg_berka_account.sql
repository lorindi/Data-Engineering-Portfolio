-- Staging for accounts: newest row of each account from Bronze, with hash keys.
with newest_account_rows_from_bronze as (
    select
        trim(ACCOUNT_ID)      as ACCOUNT_ID,
        DISTRICT_ID,
        FREQUENCY,
        DATE,
        SOURCE_FILE_NAME      as RECORD_SOURCE,
        current_timestamp()   as LOAD_DATE
    from {{ source('bronze', 'berka_account_raw') }}
    where ACCOUNT_ID is not null
    qualify row_number() over (
        partition by trim(ACCOUNT_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) = 1
)

select
    {{ automate_dv.hash(columns='ACCOUNT_ID', alias='ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['DISTRICT_ID', 'FREQUENCY', 'DATE'], alias='HASH_DIFF', is_hashdiff=true) }},
    ACCOUNT_ID,
    DISTRICT_ID,
    FREQUENCY,
    DATE,
    LOAD_DATE,
    RECORD_SOURCE
from newest_account_rows_from_bronze