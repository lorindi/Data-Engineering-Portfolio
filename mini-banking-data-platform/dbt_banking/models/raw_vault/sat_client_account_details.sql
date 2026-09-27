-- Satellite on the client and account link: role of the client (owner or disponent).
{{ automate_dv.sat(
    src_pk='CLIENT_ACCOUNT_HASH_KEY',
    src_hashdiff='HASH_DIFF',
    src_payload=['DISP_ID', 'TYPE'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_disp'
) }}