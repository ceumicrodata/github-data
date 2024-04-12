copy (with sample_users as (select 
        *
    from
        'data/users.parquet'
) 
select
    'unknown' as language,
    o.organization_id as group_id,
    u.user_id,
    1 as sorting
from 
    sample_organizations as o
inner join
    sample_users as u
on 
    o.user_id = u.user_id
group by
    group_id, 
    u.user_id)
to 'temp/organizations.parquet' (format parquet);