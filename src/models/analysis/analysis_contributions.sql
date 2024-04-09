select 
    C.user_id,
    C.project_id,
    n_commits
from
    {{ ref('sample_commits') }} as C
inner join
    {{ ref('sample_users') }} as U
on
    C.user_id = U.user_id and not U.is_organization
inner join
    {{ ref('sample_projects') }} as P
on
    C.project_id = P.project_id
order by
    C.user_id,
    C.project_id
