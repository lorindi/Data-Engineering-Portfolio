-- Reads from staging (stg_berka_loan). Runs after it, at the same time as the hub and the satellite.
-- Adds only new loan-account pairs.
--   src_pk = the code of the relationship
--   src_fk = the codes of the two hubs
{{ automate_dv.link(
    src_pk='LOAN_ACCOUNT_HASH_KEY',
    src_fk=['LOAN_HASH_KEY', 'ACCOUNT_HASH_KEY'],
    src_ldts='LOAD_DATE',
    src_source='RECORD_SOURCE',
    source_model='stg_berka_loan'
) }}

{#
  What automate_dv generates (simplified): leaves only the loan-account links that are still missing.

  WITH row_rank_1 AS (
      SELECT LOAN_ACCOUNT_HASH_KEY, LOAN_HASH_KEY, ACCOUNT_HASH_KEY, LOAD_DATE, RECORD_SOURCE
      FROM SILVER_RAW_VAULT.stg_berka_loan
      WHERE LOAN_ACCOUNT_HASH_KEY IS NOT NULL
        AND LOAN_HASH_KEY IS NOT NULL
        AND ACCOUNT_HASH_KEY IS NOT NULL
      QUALIFY ROW_NUMBER() OVER (PARTITION BY LOAN_ACCOUNT_HASH_KEY ORDER BY LOAD_DATE) = 1
  ),
  records_to_insert AS (
      SELECT a.*
      FROM row_rank_1 AS a
      LEFT JOIN SILVER_RAW_VAULT.link_loan_account AS d
          ON a.LOAN_ACCOUNT_HASH_KEY = d.LOAN_ACCOUNT_HASH_KEY
      WHERE d.LOAN_ACCOUNT_HASH_KEY IS NULL
  )
  SELECT * FROM records_to_insert
#}