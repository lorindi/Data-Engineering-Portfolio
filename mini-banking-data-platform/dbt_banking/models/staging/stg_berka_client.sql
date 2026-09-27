
with newest_client_rows_from_bronze as (
    select
        trim(CLIENT_ID)       as CLIENT_ID,
        BIRTH_NUMBER,
        DISTRICT_ID,
        SOURCE_FILE_NAME      as RECORD_SOURCE,
        current_timestamp()   as LOAD_DATE
    from {{ source('bronze', 'berka_client_raw') }}
    where CLIENT_ID is not null
    qualify row_number() over (
        partition by trim(CLIENT_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) = 1
)

select
    {{ automate_dv.hash(columns='CLIENT_ID', alias='CLIENT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['BIRTH_NUMBER', 'DISTRICT_ID'], alias='HASH_DIFF', is_hashdiff=true) }},
    CLIENT_ID,
    BIRTH_NUMBER,
    DISTRICT_ID,
    LOAD_DATE,
    RECORD_SOURCE
from newest_client_rows_from_bronze