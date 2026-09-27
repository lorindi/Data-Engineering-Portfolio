-- Hub for clients: one row for each unique client ID. Built by automate_dv, insert only.
{{ automate_dv.hub(
    src_pk='CLIENT_HASH_KEY',
    src_nk='CLIENT_ID',
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_client'
) }}