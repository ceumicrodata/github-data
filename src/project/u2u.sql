copy (with A as (
    select 
        language,
        group_id,
        user_id,
        sorting
    from
        relation
),
B as (
    select 
        group_id,
        user_id,
        sorting
    from
        relation
)
select
    A.user_id as user1,
    B.user_id as user2,
    count(*) as n_groups,
    any_value(language) as language
from 
    A 
cross join
    B
where
    A.group_id = B.group_id 
    and not A.user_id = B.user_id
    and A.sorting <= B.sorting
group by
    user1, user2, language
having
    user1 is not null
    and user2 is not null
    and language is not null)
