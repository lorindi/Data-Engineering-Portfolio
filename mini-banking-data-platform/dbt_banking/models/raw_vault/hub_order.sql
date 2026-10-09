-- Hub for permanent orders: one row for each unique order ID. Insert only.
{{ automate_dv.hub(
    src_pk='ORDER_HASH_KEY',
    src_nk='ORDER_ID',
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_order'
) }}
