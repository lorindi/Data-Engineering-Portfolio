{{ automate_dv.link(
    src_pk='LOAN_ACCOUNT_HASH_KEY',
    src_fk=['LOAN_HASH_KEY', 'ACCOUNT_HASH_KEY'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_loan'
) }}