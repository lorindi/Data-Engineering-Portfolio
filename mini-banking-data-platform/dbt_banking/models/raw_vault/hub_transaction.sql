-- Hub for transactions: one row for each unique transaction ID. Insert only.
{{ automate_dv.hub(
    src_pk='TRANSACTION_HASH_KEY',
    src_nk='TRANS_ID',
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_trans'
) }}
