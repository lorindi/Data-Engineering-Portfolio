-- Staging for dispositions: one row for each client and account pair, with hash keys for both hubs and the link.
with newest_disposition_rows_from_bronze as (
    select
        trim(CLIENT_ID)       as CLIENT_ID,
        trim(ACCOUNT_ID)      as ACCOUNT_ID,
        DISP_ID,
        TYPE,
        SOURCE_FILE_NAME      as RECORD_SOURCE,
        current_timestamp()   as LOAD_DATE
    from {{ source('bronze', 'berka_disp_raw') }}
    where CLIENT_ID is not null
      and ACCOUNT_ID is not null
    qualify row_number() over (
        partition by trim(CLIENT_ID), trim(ACCOUNT_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) = 1
)

select
    {{ automate_dv.hash(columns='CLIENT_ID', alias='CLIENT_HASH_KEY') }},
    {{ automate_dv.hash(columns='ACCOUNT_ID', alias='ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['CLIENT_ID', 'ACCOUNT_ID'], alias='CLIENT_ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['DISP_ID', 'TYPE'], alias='HASH_DIFF', is_hashdiff=true) }},
    CLIENT_ID,
    ACCOUNT_ID,
    DISP_ID,
    TYPE,
    LOAD_DATE,
    RECORD_SOURCE
from newest_disposition_rows_from_bronze