-- Satellite for client details with full history. A new row is added only when HASH_DIFF changes.
{{ automate_dv.sat(
    src_pk='CLIENT_HASH_KEY',
    src_hashdiff='HASH_DIFF',
    src_payload=['BIRTH_NUMBER', 'DISTRICT_ID'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_client'
) }}