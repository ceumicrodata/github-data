copy (with sample_users as (select 
        *
    from
        read_parquet('temp/sample_users.parquet')
),
sample_projects as 
(   select 
        project_id
    from
        read_parquet('temp/sample_projects.parquet')
) 
select
    p.project_id as group_id,
    u.user_id,
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