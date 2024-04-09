.mode markdown -header on -nullvalue NULL

{% for city in var('cities') %}
.print
.print '## {{ city }}'
.print

select 
        cast(round(n_commits, -1) as integer) as dev_n_commits,
        count(*) as freq
from (
    -- number of commits per user in the city
    select 
        city_name, 
        sample_users.user_id,
        sum(n_commits) as n_commits,
    from sample_commits
    left join sample_users
    on 
        sample_commits.user_id = sample_users.user_id
    group by 
        sample_users.user_id, city_name
    having 
        city_name like '{{ city }}%'
)
group by 
    dev_n_commits
order by
    dev_n_commits;
{% endfor %}
