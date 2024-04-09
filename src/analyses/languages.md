
select
    language,
    count(*) as count
from 
    sample_projects
group by
    language
order by
    count desc;
|  language  |  count  |
|------------|---------|
| JavaScript | 1552833 |
| Java       | 885303  |
| Python     | 727622  |
| PHP        | 490184  |
| Ruby       | 426486  |
| C++        | 312389  |

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
|  language  | count  |
|------------|--------|
| JavaScript | 265165 |
| PHP        | 115129 |
| Python     | 71449  |
| Ruby       | 40685  |
| Java       | 21060  |
| C++        | 3762   |

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
|  language  |  count   |
|------------|----------|
| JavaScript | 95153508 |
| Java       | 54771661 |
| Python     | 51140562 |
| PHP        | 33924030 |
| Ruby       | 30508006 |
| C++        | 28145028 |
