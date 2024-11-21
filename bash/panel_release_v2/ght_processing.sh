#!/bin/bash

# Set the path to the DuckDB database
DATABASE="ghtorrent_db.duckdb"

# Execute SQL commands in DuckDB
duckdb "$DATABASE" <<SQL
-- Delete commits associated with fake users
DELETE FROM commits
USING users_2019
WHERE commits.author_id = users_2019.user_id
AND users_2019.fake = 1;

-- Create a temporary table for commits with a formatted created_at column
CREATE TABLE commits_temp AS
SELECT
    author_id,
    project_id,
    CAST(created_at AS DATE) AS created_at
FROM
    commits;

-- Replace the old commits table with the new one
DROP TABLE commits;
ALTER TABLE commits_temp RENAME TO commits;

-- Generate developer join sequence
CREATE TABLE developer_join_sequence AS
SELECT
    project_id,
    author_id,
    MIN(created_at) AS first_commit_date
FROM
    commits
GROUP BY
    project_id, author_id
ORDER BY
    project_id, first_commit_date;

ALTER TABLE commits ADD COLUMN quarter_start DATE;

UPDATE commits
  SET quarter_start = DATE_TRUNC('quarter', created_at);

-- Group commits by quarter
CREATE TABLE commit_groups AS
SELECT
    author_id,
    project_id,
    quarter_start,
    COUNT(*) AS total_commits,
    COUNT(DISTINCT created_at) AS unique_commit_dates
FROM
    commits
GROUP BY
    author_id, project_id, quarter_start;

-- Trim the projects table
CREATE TABLE projects_trimmed AS
SELECT
    id,
    owner_id,
    name,
    language
FROM
    projects;

-- Drop the old projects table
DROP TABLE projects;

-- Split projects_trimmed into two parts
CREATE TABLE projects_trimmed_part1 AS
SELECT *
FROM projects_trimmed
LIMIT CAST((SELECT COUNT(*) FROM projects_trimmed) / 2 AS INTEGER);

CREATE TABLE projects_trimmed_part2 AS
SELECT *
FROM projects_trimmed
WHERE id NOT IN (SELECT id FROM projects_trimmed_part1);


CREATE TABLE watchers_temp AS
SELECT
    repo_id,
    user_id,
    CAST(created_at AS DATE) AS created_at
FROM
    watchers;



-- Export tables to Parquet format
COPY developer_join_sequence TO 'output/developer_join_sequence.parquet' (FORMAT 'parquet');
COPY commit_groups TO 'output/commit_groups.parquet' (FORMAT 'parquet');
COPY projects_trimmed_part1 TO 'output/projects_trimmed_part1.parquet' (FORMAT 'parquet');
COPY projects_trimmed_part2 TO 'output/projects_trimmed_part2.parquet' (FORMAT 'parquet');
COPY users_2019 TO 'output/users_2019.parquet' (FORMAT 'parquet');
COPY followers TO 'output/followers.parquet' (FORMAT 'parquet');
COPY watchers_temp TO 'output/watchers.parquet' (FORMAT 'parquet');
COPY organization_members TO 'output/organization_members.parquet' (FORMAT 'parquet');
COPY users_2021 TO 'output/users_2021.parquet' (FORMAT 'parquet');
SQL

# Final message
echo "Data processing and Parquet file generation completed successfully!"