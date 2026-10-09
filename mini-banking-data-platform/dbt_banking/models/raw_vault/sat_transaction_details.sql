-- Satellite for transaction details: date, type, amount, balance after the transaction and the other side of the payment.
{{ automate_dv.sat(
    src_pk='TRANSACTION_HASH_KEY',
    src_hashdiff='HASH_DIFF',
    src_payload=['DATE', 'TYPE', 'OPERATION', 'AMOUNT', 'BALANCE', 'K_SYMBOL', 'BANK', 'PARTNER_ACCOUNT'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_trans'
) }}
