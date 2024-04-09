select * from num_commits
where n_commits >= {{ var('min_commits') }}