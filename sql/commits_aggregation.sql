CREATE OR REPLACE TABLE users_fake AS 
SELECT * FROM 'data/github/users_fake.parquet';

CREATE OR REPLACE TABLE commits_filtered AS
SELECT * FROM commits
WHERE comitter_id NOT IN (SELECT user_id FROM users_fake);


CREATE OR REPLACE TABLE ranked_committers AS
SELECT 
    repo_id, 
    comitter_id, 
    MIN(created_at) AS min_created_at,
    ROW_NUMBER() OVER (PARTITION BY repo_id ORDER BY MIN(created_at)) AS rank
FROM 
    commit_groups_filtered
GROUP BY 
    repo_id, 
    comitter_id;

--- Produce .parquet file from ranked_committers
COPY ranked_committers TO 'github/ranked_committers.parquet' (FORMAT 'parquet');


--- Produce commit_groups data from


--- Produce coder_commit_days data