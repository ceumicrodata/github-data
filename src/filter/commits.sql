attach 'temp/ghtorrent.db' as ghtorrent (type duckdb);
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
    p.project_id,
    u.user_id,
    date_trunc('day', created_at) as created_at,
    count(*) as n_commits
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
    p.project_id, 
    u.user_id,
    created_at)
to 'temp/commits.parquet' (format parquet);