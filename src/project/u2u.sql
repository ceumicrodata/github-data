copy (with A as (
    select 
        group_id,
        user_id
    from
        relation
),
B as (
    select 
        group_id,
        user_id
    from
        relation
)
select
    A.user_id as user1,
    B.user_id as user2,
    count(*) as n_groups
from 
    A 
cross join
    B
where
    A.group_id = B.group_id 
    and not A.user_id = B.user_id
group by
    user1, user2
having
    user1 is not null
    and user2 is not null)
