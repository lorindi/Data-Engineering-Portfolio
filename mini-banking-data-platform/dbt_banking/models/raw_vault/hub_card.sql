-- Hub for credit cards: one row for each unique card ID. Insert only.
{{ automate_dv.hub(
    src_pk='CARD_HASH_KEY',
    src_nk='CARD_ID',
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_card'
) }}
