copy (with sample_users as (select 
        *
    from
        read_parquet('temp/sample_users.parquet')
) 
select
    i.issue_id as group_id,
    u.user_id,
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