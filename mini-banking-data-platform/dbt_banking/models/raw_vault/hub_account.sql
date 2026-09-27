-- Hub for bank accounts: one row for each unique account ID. Insert only.
{{ automate_dv.hub(
    src_pk='ACCOUNT_HASH_KEY',
    src_nk='ACCOUNT_ID',
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_account'
) }}