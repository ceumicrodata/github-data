copy (with sample_users as (select 
        *
    from
        'data/users.parquet'
) 
select
    'unknown' as language,
    i.issue_id as group_id,
    u.user_id,
    min(i.created_at) as sorting
from 
    issue_events as i
inner join
    sample_users as u
on 
    i.user_id = u.user_id
group by
    group_id, 
    u.user_id)
to 'temp/issues.parquet' (format parquet);