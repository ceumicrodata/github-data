
select 
    sum(n_commits)
from 
    "ghtorrent"."main"."sample_commits";
| sum(n_commits) |
|----------------|
| 293642795      |

select 
    n_commits,
    count(*) as freq
from 
    "ghtorrent"."main"."sample_commits"
group by 
    n_commits
order by
    n_commits
limit 50;
| n_commits |  freq  |
|-----------|--------|
| 4         | 390732 |
| 5         | 322570 |
| 6         | 284185 |
| 7         | 236129 |
| 8         | 201653 |
| 9         | 173901 |
| 10        | 412152 |
| 11        | 353862 |
| 12        | 314925 |
| 13        | 276312 |
| 14        | 246024 |
| 15        | 221350 |
| 16        | 201956 |
| 17        | 180651 |
| 18        | 164575 |
| 19        | 151541 |
| 20        | 142651 |
| 21        | 129943 |
| 22        | 118575 |
| 23        | 110024 |
| 24        | 102148 |
| 25        | 94605  |
| 26        | 89059  |
| 27        | 83441  |
| 28        | 77444  |
| 29        | 72792  |
| 30        | 68449  |
| 31        | 64593  |
| 32        | 61026  |
| 33        | 57675  |
| 34        | 54774  |
| 35        | 51578  |
| 36        | 49471  |
| 37        | 46984  |
| 38        | 44350  |
| 39        | 41985  |
| 40        | 40436  |
| 41        | 38291  |
| 42        | 36852  |
| 43        | 34860  |
| 44        | 33614  |
| 45        | 32290  |
| 46        | 30820  |
| 47        | 29508  |
| 48        | 28089  |
| 49        | 27147  |
| 50        | 26117  |
| 51        | 25267  |
| 52        | 24189  |
| 53        | 23159  |

select
    cast(round(n_users, -1) as int) as n_users_100,
    count(*) as freq
from (
    select 
        project_id,
        count(distinct user_id) as n_users
    from 
        "ghtorrent"."main"."sample_commits"
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
| n_users_100 |  freq   |
|-------------|---------|
| 30          | 1609    |
| 20          | 7770    |
| 10          | 131660  |
| 0           | 4253778 |
