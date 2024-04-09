select 
    L.project_id,
    owner_id,
    L.project_name,
    case 
        when language is null then 
            case 
                when platform = 'NPM' then 'JavaScript'
                when platform = 'Maven' then 'Java'
                when platform = 'RubyGems' then 'Ruby'
                when platform = 'Packagist' then 'PHP'
                when platform = 'NuGet' then 'C#'
                when platform = 'Pypi' then 'Python'
                when platform = 'Bower' then 'JavaScript'
                when platform = 'CocoaPods' then 'Objective-C'
                when platform = 'CRAN' then 'R'
                when platform = 'Cargo' then 'Rust'
                when platform = 'Hex' then 'Elixir'
                when platform = 'Pub' then 'Dart'
                when platform = 'Conda' then 'Python'
                when platform = 'Go' then 'Go'
                when platform = 'Hackage' then 'Haskell'
                when platform = 'CPAN' then 'Perl'
                when platform = 'Clojars' then 'Clojure'
                when platform = 'Meteor' then 'JavaScript'
                when platform = 'Julia' then 'Julia'
                when platform = 'Dub' then 'D'
                when platform = 'Elm' then 'Elm'
                when platform = 'Swift' then 'Swift'
                when platform = 'Rust' then 'Rust'
                when platform = 'Racket' then 'Racket'
                when platform = 'Nimble' then 'Nim'
                when platform = 'Haxelib' then 'Haxe'
                when platform = 'Paket' then 'F#'
                when platform = 'Alcatraz' then 'Objective-C'
                when platform = 'Carthage' then 'Swift'  
                else NULL
            end 
        else language 
        end as language,
    forked_from,
    libraries_id,
    (libraries_id is not null) as is_in_libraries,
    platform,
    downstream_libraries,
    downstream_repositories as downstream_projects,
    n_contributors,
    total_commits
from 
(select 
    column00 as project_id,
    column02 as owner_id,
    regexp_split_to_array(column01, '/')[5] || '/' || regexp_split_to_array(column01, '/')[6] as project_name,
    column05 as language,
    column07 as forked_from
from 
    projects) as L
left join (
        -- github repositories are not unique in the libraries table
        select 
            project_name,
            any_value(libraries_id) as libraries_id,
            any_value(platform) as platform,
            any_value(downstream_libraries) as downstream_libraries,
            any_value(downstream_repositories) as downstream_repositories
        from libraries
        group by project_name
    ) as R
on
    L.project_name = R.project_name
    and R.project_name is not null
    and R.project_name != ''
    and R.project_name != '/'
inner join (
    select
        project_id,
        count(distinct user_id) as n_contributors,
        sum(n_commits) as total_commits
    from
        {{ ref('src_commits') }}
    group by
        project_id
    having
        n_contributors between 1 and {{ var('max_users') }}
) as C
on
    L.project_id = C.project_id

