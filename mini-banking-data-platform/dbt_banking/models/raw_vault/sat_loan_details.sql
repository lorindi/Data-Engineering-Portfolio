{{
    automate_dv.sat(
        src_pk='LOAN_HASH_KEY',
        src_hashdiff='HASH_DIFF',
        src_payload=['DATE', 'AMOUNT', 'DURATION', 'PAYMENTS', 'STATUS'],
        src_ldts='LOAD_DATE',
        src_source='RECORD_SOURCE',
        source_model='stg_berka_loan'

    )
}}