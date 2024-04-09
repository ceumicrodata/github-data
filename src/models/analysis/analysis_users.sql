select 
    C.user_id,
    P.language,
    is_library,
    count(distinct C.project_id) as n_projects,
    avg(n_downstream_libraries) as avg_n_downstream_libraries,
    avg(n_downstream_projects) as avg_n_downstream_projects,
    avg(n_stars) as avg_n_stars,
    avg(n_issues) as avg_n_issues,
    avg(n_closed_issues) as avg_n_closed_issues,
    avg(n_contributors) as avg_n_contributors,
    avg(n_commits) as avg_n_commits,
    avg(total_commits) as avg_total_commits,
    avg(solo_authored_stars) as solo_authored_stars
from
    {{ ref('analysis_contributions') }} as C
inner join
    {{ ref('analysis_projects') }} as P
on
    C.project_id = P.project_id
left join (select 
            user_id,
            PP.language,
            avg(PP.n_stars) as solo_authored_stars
        from {{ ref('analysis_contributions') }} as CC
        inner join {{ ref('analysis_projects') }} as PP
        on CC.project_id = PP.project_id
            and PP.is_library = 1
            and (n_commits >= {{ var('min_share_solo_authored') }} * total_commits)
        group by
            user_id, PP.language
    ) as S
on
    C.user_id = S.user_id
group by
    C.user_id,
    P.language,
    is_library
order by
    C.user_id,
    P.language,
    is_library
