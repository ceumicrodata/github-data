select 
    column0 as project_id,
    count(column1) as stars
from 
    watchers
group by
    project_id
