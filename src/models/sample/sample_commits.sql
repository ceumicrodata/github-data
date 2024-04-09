-- only commits to sample projects
select * from {{ ref('src_commits') }}
where project_id in (
    select project_id from {{ ref('sample_projects') }}
)