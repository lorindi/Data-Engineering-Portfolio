-- Reads from staging (stg_berka_loan). Runs after it, at the same time as the satellite and the link.
-- Keeps one row per loan and adds only new loans.
--   src_pk       = the code of the loan
--   src_nk       = the real loan number
--   src_ldts     = when the row was loaded
--   src_source   = from which file
--   source_model = the staging view to read from
{{
    automate_dv.hub(
        src_pk='LOAN_HASH_KEY',
        src_nk='LOAN_ID',
        src_ldts='LOAD_DATE',
        src_source='RECORD_SOURCE',
        source_model='stg_berka_loan'
    )
}}

{#
  What automate_dv generates (simplified): records only the new loans.

  WITH row_rank_1 AS (
      SELECT LOAN_HASH_KEY, LOAN_ID, LOAD_DATE, RECORD_SOURCE
      FROM SILVER_RAW_VAULT.stg_berka_loan
      WHERE LOAN_HASH_KEY IS NOT NULL
      QUALIFY ROW_NUMBER() OVER (PARTITION BY LOAN_HASH_KEY ORDER BY LOAD_DATE) = 1
  ),
  records_to_insert AS (
      SELECT a.*
      FROM row_rank_1 AS a
      LEFT JOIN SILVER_RAW_VAULT.hub_loan AS d
          ON a.LOAN_HASH_KEY = d.LOAN_HASH_KEY
      WHERE d.LOAN_HASH_KEY IS NULL
  )
  SELECT * FROM records_to_insert
#}