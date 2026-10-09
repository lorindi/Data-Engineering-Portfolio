-- Satellite for card details with full history: card type, issue date and the disposition behind the card.
{{ automate_dv.sat(
    src_pk='CARD_HASH_KEY',
    src_hashdiff='HASH_DIFF',
    src_payload=['DISP_ID', 'TYPE', 'ISSUED'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_card'
) }}
