-- Accounts whose bank branch district is missing from the district reference table.
-- The test passes when this query returns no rows.
select
    account_versions.ACCOUNT_HASH_KEY,
    account_versions.DISTRICT_ID
from {{ ref('sat_account_details') }} as account_versions
left join {{ ref('ref_district') }} as districts
    on districts.DISTRICT_ID = trim(account_versions.DISTRICT_ID)
where account_versions.DISTRICT_ID is not null
  and districts.DISTRICT_ID is null
