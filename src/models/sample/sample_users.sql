/*
only keep users who have commited to main language projects
or are owners of main language projects
*/
select * from {{ ref('src_users') }}
where user_id in (
    select user_id from {{ ref('sample_commits') }}
    union
    select owner_id as user_id from {{ ref('sample_projects') }}
)