.mode markdown -header on -nullvalue NULL
.echo on

select
    language,
    count(*) as count
from 
    sample_projects
group by
    language
order by
    count desc;

select
    language,
    count(*) as count
from 
    sample_projects
where
    is_in_libraries
group by
    language
order by
    count desc;

select
    language,
    sum(n_commits) as count
from 
    sample_projects as L
inner join
    sample_commits as R
on 
    L.project_id = R.project_id
group by
    language
order by
    count desc;


