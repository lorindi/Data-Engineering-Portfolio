-- Cards in Bronze whose disposition does not exist.
-- The card staging model uses an inner join, so such cards would be lost without a warning. This test makes the loss visible.
-- The test passes when this query returns no rows.
select
    cards.CARD_ID,
    cards.DISP_ID
from {{ source('bronze', 'berka_card_raw') }} as cards
left join {{ source('bronze', 'berka_disp_raw') }} as dispositions
    on trim(dispositions.DISP_ID) = trim(cards.DISP_ID)
where cards.CARD_ID is not null
  and dispositions.DISP_ID is null
