-- Reads from staging (stg_berka_loan). Runs after it, at the same time as the hub and the link.
-- Adds a new version only when the loan details change.
--   src_pk       = which loan
--   src_hashdiff = fingerprint of the details
--   src_payload  = the details to keep with history
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

{#
  What automate_dv generates (simplified):
  compares the fingerprint of the new data with the last recorded version.
  If the loan is new or something has changed, a new version is saved. Otherwise nothing happens.

  WITH source_data AS (
      SELECT LOAN_HASH_KEY, HASH_DIFF, DATE, AMOUNT, ..., STATUS, LOAD_DATE, RECORD_SOURCE
      FROM SILVER_RAW_VAULT.stg_berka_loan
  ),
  latest_records AS (
      SELECT LOAN_HASH_KEY, HASH_DIFF
      FROM SILVER_RAW_VAULT.sat_loan_details
      QUALIFY ROW_NUMBER() OVER (PARTITION BY LOAN_HASH_KEY ORDER BY LOAD_DATE DESC) = 1
  ),
  unique_source_records AS (
      SELECT sd.*
      FROM source_data AS sd
      LEFT JOIN latest_records AS lr ON sd.LOAN_HASH_KEY = lr.LOAN_HASH_KEY
      QUALIFY sd.HASH_DIFF != <the last HASH_DIFF, or 'FFFFFFFF' if the loan is new>
  )
  SELECT * FROM unique_source_records
#}