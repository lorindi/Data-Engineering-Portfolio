-- Satellite for permanent order details with full history: who receives the money, how much, and for what.
{{ automate_dv.sat(
    src_pk='ORDER_HASH_KEY',
    src_hashdiff='HASH_DIFF',
    src_payload=['BANK_TO', 'ACCOUNT_TO', 'AMOUNT', 'K_SYMBOL'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_order'
) }}
