copy (with sample_users as (select 
        *
    from
        'data/users.parquet'
) 
select
    i.issue_id as group_id,
    u.user_id,
from 
    issue_comments as i
inner join
    sample_users as u
on 
    i.user_id = u.user_id
group by
    group_id, 
    u.user_id)
to 'temp/comments.parquet' (format parquet);