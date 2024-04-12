copy (select
    user_id,
    round(lon, 3) as lon,
    round(lat, 3) as lat,
    city_name,
    country_code
from
    sample_users
where
    country_code is not null
    and city_name is not null
)
to 'data/users.csv' (format csv);
copy (select
    *
from
    sample_projects)
to 'data/projects.csv' (format csv);