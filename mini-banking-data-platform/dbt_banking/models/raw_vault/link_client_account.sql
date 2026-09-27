-- Link between clients and accounts. One account can have more than one client. Insert only.
{{ automate_dv.link(
    src_pk='CLIENT_ACCOUNT_HASH_KEY',
    src_fk=['CLIENT_HASH_KEY', 'ACCOUNT_HASH_KEY'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_disp'
) }}