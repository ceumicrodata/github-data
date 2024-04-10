copy (with sample_users as (select 
        *
    from
        read_parquet('temp/sample_users.parquet')
) 
select
    o.organization_id as group_id,
    u.user_id,
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