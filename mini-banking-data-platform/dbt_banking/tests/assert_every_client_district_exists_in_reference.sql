-- Clients whose district is missing from the district reference table.
-- The test passes when this query returns no rows.
select
    client_versions.CLIENT_HASH_KEY,
    client_versions.DISTRICT_ID
from {{ ref('sat_client_details') }} as client_versions
left join {{ ref('ref_district') }} as districts
    on districts.DISTRICT_ID = trim(client_versions.DISTRICT_ID)
where client_versions.DISTRICT_ID is not null
  and districts.DISTRICT_ID is null
