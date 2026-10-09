-- Link between transactions and accounts: which account each transaction belongs to. Insert only.
{{ automate_dv.link(
    src_pk='TRANSACTION_ACCOUNT_HASH_KEY',
    src_fk=['TRANSACTION_HASH_KEY', 'ACCOUNT_HASH_KEY'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_trans'
) }}
