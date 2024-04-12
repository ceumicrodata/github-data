copy (with sample_users as (select 
        *
    from
        'data/users.parquet'
),
sample_projects as 
(   select 
        project_id,
        owner_id
    from
        'data/projects.parquet'
) 
select
    p.owner_id as user1,
    c.author_id as user2,
    count(distinct p.project_id) as n_groups
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
    user2
having
    not user1 = user2)
to 'temp/u2u_owners.parquet' (format parquet);