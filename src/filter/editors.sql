copy (with sample_users as (select 
        *
    from
        read_csv_auto('data/users.csv')
) 
select
    p.column0 as group_id,
    u.user_id,
from 
    project_members as p
inner join
    sample_users as u
on 
    p.column1 = u.user_id
group by
    group_id, 
    u.user_id)
to 'temp/editors.parquet' (format parquet);