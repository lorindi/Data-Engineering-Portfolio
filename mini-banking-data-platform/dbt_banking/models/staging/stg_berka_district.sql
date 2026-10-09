-- Staging for districts. Gives clear names to columns A1 to A16. Values stay as text, "?" is kept.
select
    trim(A1)                as DISTRICT_ID,
    A2                      as DISTRICT_NAME,
    A3                      as REGION_NAME,
    A4                      as NUMBER_OF_INHABITANTS,
    A5                      as MUNICIPALITIES_UNDER_500_INHABITANTS,
    A6                      as MUNICIPALITIES_500_TO_1999_INHABITANTS,
    A7                      as MUNICIPALITIES_2000_TO_9999_INHABITANTS,
    A8                      as MUNICIPALITIES_OVER_10000_INHABITANTS,
    A9                      as NUMBER_OF_CITIES,
    A10                     as PERCENT_OF_URBAN_INHABITANTS,
    A11                     as AVERAGE_SALARY,
    A12                     as UNEMPLOYMENT_RATE_1995,
    A13                     as UNEMPLOYMENT_RATE_1996,
    A14                     as ENTREPRENEURS_PER_1000_INHABITANTS,
    A15                     as NUMBER_OF_CRIMES_1995,
    A16                     as NUMBER_OF_CRIMES_1996,
    SOURCE_FILE_NAME        as RECORD_SOURCE,
    current_timestamp()     as LOAD_DATE
from {{ source('bronze', 'berka_district_raw') }}
where A1 is not null