/*
only select organizations that are associated with the sample users
or are sample users themselves
*/
select * from {{ ref('src_organizations') }}
where user_id in (
    select user_id from {{ ref('sample_users') }}
)
or organization_id in (
    select user_id from {{ ref('sample_users') }}
)