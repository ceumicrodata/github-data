select 
    column00 as user_id,
    column01 as user_name,
    column02 as company_name,
    column03 as created_at,
    column04 = 'ORG' as is_organization,
    column07 as lon,
    column08 as lat,
    upper(column09) as country_code,
    column12 as city_name
from 
    users
where
    column05 = 0 and column06 = 0
    and user_id in (
        select user_id from (
            select user_id, count(*) as n_projects
            from {{ ref('src_commits') }}
            group by user_id
            having n_projects <= {{ var('max_projects') }}
        )
    )
