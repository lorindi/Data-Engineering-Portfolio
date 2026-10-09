-- Link between a card, its client and its account. Three hubs in one link: a card belongs to one person for one account. Insert only.
{{ automate_dv.link(
    src_pk='CARD_CLIENT_ACCOUNT_HASH_KEY',
    src_fk=['CARD_HASH_KEY', 'CLIENT_HASH_KEY', 'ACCOUNT_HASH_KEY'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_card'
) }}
