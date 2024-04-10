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
to 'temp/sample_users.parquet' (format parquet);
copy (select
    *
from
    sample_projects)
to 'temp/sample_projects.parquet' (format parquet);