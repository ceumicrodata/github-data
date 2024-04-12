copy (with sample_users as (select 
        *
    from
        'data/users.parquet'
),
sample_projects as (select 
        *
    from
        'data/projects.parquet'
)  
select
    any_value(language) as language, 
    p.column0 as group_id,
    u.user_id,
    1 as sorting
from 
    project_members as p
inner join
    sample_users as u
on 
    p.column1 = u.user_id
inner join
    sample_projects
on 
    sample_projects.project_id = p.column0
group by
    group_id, 
    u.user_id)
to 'temp/editors.parquet' (format parquet);