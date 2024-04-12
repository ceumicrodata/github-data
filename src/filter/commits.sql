copy (with sample_users as (select 
        *
    from
        'data/users.parquet'
),
sample_projects as 
(   select 
        project_id
    from
        'data/projects.parquet'
) 
select
    p.project_id as group_id,
    u.user_id,
    min(c.created_at) as sorting
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
    group_id, 
    u.user_id)
to 'temp/commits.parquet' (format parquet);