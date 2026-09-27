-- Satellite for account details with full history. A new row is added only when HASH_DIFF changes.
{{ automate_dv.sat(
    src_pk='ACCOUNT_HASH_KEY',
    src_hashdiff='HASH_DIFF',
    src_payload=['DISTRICT_ID', 'FREQUENCY', 'DATE'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_account'
) }}