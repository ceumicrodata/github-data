copy (
with commits as (
    select 
        user1,
        user2,
        n_groups as n_projects
    from 'temp/u2u_commits.csv'
),
issues as (
    select 
        user1,
        user2,
        n_groups as n_issues
    from 'temp/u2u_issues.csv'
),
comments as (
    select 
        user1,
        user2,
        n_groups as n_threads
    from 'temp/u2u_comments.csv'
)
select
    coalesce(c.user1, i.user1, t.user1) as user1,
    coalesce(c.user2, i.user2, t.user2) as user2,
    coalesce(n_projects, 0) as n_projects,
    coalesce(n_issues, 0) as n_issues,
    coalesce(n_threads, 0) as n_threads,
from
    commits as c
full outer join
    issues as i
on
    c.user1 = i.user1
    and c.user2 = i.user2
full outer join
    comments as t
on
    c.user1 = t.user1
    and c.user2 = t.user2)
to 'data/u2u.csv';
