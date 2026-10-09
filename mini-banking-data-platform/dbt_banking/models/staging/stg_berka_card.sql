-- Staging for cards. A card points to a disposition, not to a client. The join with dispositions finds the client and the account behind each card,
-- because in Data Vault a link can point only to hubs, never to another link.
with newest_card_rows_from_bronze as (
    select
        trim(CARD_ID)           as CARD_ID,
        trim(DISP_ID)           as DISP_ID,
        TYPE,
        ISSUED,
        SOURCE_FILE_NAME        as RECORD_SOURCE,
        current_timestamp()     as LOAD_DATE
    from {{ source('bronze', 'berka_card_raw') }}
    where CARD_ID is not null
      and DISP_ID is not null
    qualify row_number() over (
        partition by trim(CARD_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) = 1
),

newest_disposition_rows_from_bronze as (
    select
        trim(DISP_ID)           as DISP_ID,
        trim(CLIENT_ID)         as CLIENT_ID,
        trim(ACCOUNT_ID)        as ACCOUNT_ID
    from {{ source('bronze', 'berka_disp_raw') }}
    where DISP_ID is not null
    qualify row_number() over (
        partition by trim(DISP_ID)
        order by SOURCE_FILE_LAST_MODIFIED desc, SOURCE_FILE_ROW_NUMBER desc
    ) = 1
),

-- Inner join: a card without a disposition cannot be linked. The test assert_every_card_has_a_disposition catches such cards.
cards_with_client_and_account as (
    select
        cards.CARD_ID,
        cards.DISP_ID,
        dispositions.CLIENT_ID,
        dispositions.ACCOUNT_ID,
        cards.TYPE,
        cards.ISSUED,
        cards.RECORD_SOURCE,
        cards.LOAD_DATE
    from newest_card_rows_from_bronze as cards
    inner join newest_disposition_rows_from_bronze as dispositions
        on dispositions.DISP_ID = cards.DISP_ID
)

select
    {{ automate_dv.hash(columns='CARD_ID', alias='CARD_HASH_KEY') }},
    {{ automate_dv.hash(columns='CLIENT_ID', alias='CLIENT_HASH_KEY') }},
    {{ automate_dv.hash(columns='ACCOUNT_ID', alias='ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['CARD_ID', 'CLIENT_ID', 'ACCOUNT_ID'], alias='CARD_CLIENT_ACCOUNT_HASH_KEY') }},
    {{ automate_dv.hash(columns=['DISP_ID', 'TYPE', 'ISSUED'], alias='HASH_DIFF', is_hashdiff=true) }},
    CARD_ID,
    DISP_ID,
    CLIENT_ID,
    ACCOUNT_ID,
    TYPE,
    ISSUED,
    LOAD_DATE,
    RECORD_SOURCE
from cards_with_client_and_account
