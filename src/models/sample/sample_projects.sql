-- only projects with main language in the top few
select * 
from 
    {{ ref('src_projects') }} as L
left join 
    {{ ref('src_stars') }} as C
on 
    L.project_id = C.project_id
left join 
    {{ ref('src_issues') }} as R
on 
    L.project_id = R.project_id
where 
    language in {{ var('languages') }}
    and total_commits >= {{ var('min_total_commits') }}
    and forked_from is null