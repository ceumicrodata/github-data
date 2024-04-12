copy (with sample_users as (select 
        *
    from
        'data/users.parquet'
),
sample_projects as 
(   select 
        project_id,
        owner_id,
        language
    from
        'data/projects.parquet'
) 
select
    p.owner_id as user1,
    c.author_id as user2,
    count(distinct p.project_id) as n_groups,
    any_value(p.language) as language
from 
    commits as c
inner join 
    sample_projects as p
on 
    try_cast(c.project_id as integer) = p.project_id
inner join
    sample_users as u
on 
    c.author_id = u.user_id
group by
    user1, 
    user2,
    language
having
    not user1 = user2
    and user1 is not null
    and user2 is not null
    and language is not null)
to 'temp/u2u_owners.parquet' (format parquet);