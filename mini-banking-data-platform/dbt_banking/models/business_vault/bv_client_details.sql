-- Business vault for clients. Takes the current version of each client and reads gender and birth date from the birth number.
-- Birth number rule (Czech rodne cislo, format YYMMDD):
--   YY -> year of birth (19YY)
--   MM -> month; if MM > 50 the client is a woman and the real month is MM - 50
--   DD -> day of birth
-- Example: 706213 -> month 62 > 50 -> woman, born 13.12.1970
-- The birth number itself does not leave this model (data minimization).

with current_client_details as (
    select
        CLIENT_HASH_KEY,
        BIRTH_NUMBER,
        DISTRICT_ID
    from {{ ref('sat_client_details') }}
    qualify row_number() over (
        partition by CLIENT_HASH_KEY
        order by LOAD_DATE desc
    ) = 1
),

birth_number_parts as (
    select
        hub.CLIENT_HASH_KEY,
        hub.CLIENT_ID,
        trim(details.DISTRICT_ID) as DISTRICT_ID,
        try_to_number(substr(trim(details.BIRTH_NUMBER), 1, 2)) as BIRTH_YEAR_TWO_DIGITS,
        try_to_number(substr(trim(details.BIRTH_NUMBER), 3, 2)) as BIRTH_MONTH_WITH_GENDER_CODE,
        try_to_number(substr(trim(details.BIRTH_NUMBER), 5, 2)) as BIRTH_DAY
    from {{ ref('hub_client') }} as hub
    inner join current_client_details as details
        on details.CLIENT_HASH_KEY = hub.CLIENT_HASH_KEY
)

select
    CLIENT_HASH_KEY,
    CLIENT_ID,
    DISTRICT_ID,
    case
        when BIRTH_MONTH_WITH_GENDER_CODE > 50 then 'F'
        else 'M'
    end as GENDER,
    date_from_parts(
        1900 + BIRTH_YEAR_TWO_DIGITS,
        case
            when BIRTH_MONTH_WITH_GENDER_CODE > 50 then BIRTH_MONTH_WITH_GENDER_CODE - 50
            else BIRTH_MONTH_WITH_GENDER_CODE
        end,
        BIRTH_DAY
    ) as BIRTH_DATE
from birth_number_parts