.mode markdown -header on -nullvalue NULL
.echo on

select 
    sum(n_commits)
from 
    {{ ref('sample_commits') }};

select 
    n_commits,
    count(*) as freq
from 
    {{ ref('sample_commits') }}
group by 
    n_commits
order by
    n_commits
limit 50;

select
    cast(round(n_users, -1) as int) as n_users_100,
    count(*) as freq
from (
    select 
        project_id,
        count(distinct user_id) as n_users
    from 
        {{ ref('sample_commits') }}
    group by
        project_id
    having 
        n_users <= 100
)
group by 
    n_users_100
order by
    n_users_100 desc
limit 50;