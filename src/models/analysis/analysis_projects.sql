select
    project_id,
    language,
    case when is_in_libraries then 1
        else 0
        end as is_library,
    case when downstream_libraries is null then 0
        else downstream_libraries
        end as n_downstream_libraries,
    case when downstream_projects is null then 0
        else downstream_projects
        end as n_downstream_projects,
    case when stars is null then 0
        else stars
        end as n_stars, 
    case when n_issues is null then 0
        else n_issues
        end as n_issues,
    case when n_closed is null then 0
        else n_closed
        end as n_closed_issues,
    n_contributors,
    total_commits
from
    {{ ref('sample_projects') }}
