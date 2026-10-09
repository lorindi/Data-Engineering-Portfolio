-- Link between permanent orders and accounts: which account pays each order. Insert only.
{{ automate_dv.link(
    src_pk='ORDER_ACCOUNT_HASH_KEY',
    src_fk=['ORDER_HASH_KEY', 'ACCOUNT_HASH_KEY'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_order'
) }}
