copy (select
    *
from 
    'temp/commit_days.parquet' as c
where
    c.user_id in (select user_id from 'data/users.parquet') and
    try_cast(c.project_id as integer) in (select project_id from 'data/projects.parquet')
)
to 'data/days.parquet' (format parquet);