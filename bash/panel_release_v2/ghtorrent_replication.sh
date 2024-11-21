#!/bin/bash

# Define the path to the DuckDB database directory
DATABASE_DIR=~/Desktop/duckdb_database_ghtorrent
DATABASE_FILE="$DATABASE_DIR/ghtorrent_db.duckdb"

# Step 1: Check if directory "duckdb_database_ghtorrent" exists, create if not
if [ ! -d "$DATABASE_DIR" ]; then
  mkdir -p "$DATABASE_DIR"
  echo "Directory '$DATABASE_DIR' created."
else
  echo "Directory '$DATABASE_DIR' already exists."
fi

cd github_release

# Step 2: Create a valid DuckDB database file named "ghtorrent_db.duckdb" if it doesn't already exist
if [ ! -f "$DATABASE_FILE" ]; then
  # Initialize the database file by running a simple command
  duckdb "$DATABASE_FILE" "SELECT 1;" > /dev/null 2>&1
  echo "DuckDB database file '$DATABASE_FILE' created successfully."
else
  echo "DuckDB database file '$DATABASE_FILE' already exists."
fi

# Step 3: Load the CSV files into DuckDB using read_csv_auto with CREATE TABLE IF NOT EXISTS
duckdb "$DATABASE_FILE" <<EOF
-- Load users.csv
CREATE TABLE IF NOT EXISTS users_2021 AS SELECT * FROM read_csv_auto('../../ghtorrent/mysql-2019-06-01/2021_supplementary/users.csv', ignore_errors = TRUE);

CREATE TABLE IF NOT EXISTS users_2019 AS SELECT * FROM read_csv_auto('../../ghtorrent/mysql-2019-06-01/users.csv', ignore_errors = TRUE);


-- Load commits.csv
CREATE TABLE IF NOT EXISTS commits AS 
SELECT 
    column2 AS author_id,
    column4 AS project_id,
    column5 AS created_at
FROM 
    read_csv_auto('../../ghtorrent/mysql-2019-06-01/commits.csv', ignore_errors = TRUE);
-- Load projects.csv
CREATE TABLE IF NOT EXISTS projects AS SELECT * FROM read_csv_auto('../../ghtorrent/mysql-2019-06-01/projects.csv', ignore_errors = TRUE);

-- Load followers.csv
CREATE TABLE IF NOT EXISTS followers AS SELECT * FROM read_csv_auto('../../ghtorrent/mysql-2019-06-01/followers.csv', ignore_errors = TRUE);

-- Load watchers.csv
CREATE TABLE IF NOT EXISTS watchers AS SELECT * FROM read_csv_auto('../../ghtorrent/mysql-2019-06-01/2021_supplementary/watchers.csv', ignore_errors = TRUE);

-- Load organization_members.csv
CREATE TABLE IF NOT EXISTS organization_members AS SELECT * FROM read_csv_auto('../../ghtorrent/mysql-2019-06-01/organization_members.csv', ignore_errors = TRUE);
EOF

# Step 4: Rename columns directly in each table
duckdb "$DATABASE_FILE" <<EOF
-- Rename columns in users table
ALTER TABLE users_2019 RENAME column00 TO user_id;
ALTER TABLE users_2019 RENAME column01 TO login;
ALTER TABLE users_2019 RENAME column02 TO company;
ALTER TABLE users_2019 RENAME column03 TO created_at;
ALTER TABLE users_2019 RENAME column04 TO type;
ALTER TABLE users_2019 RENAME column05 TO fake;
ALTER TABLE users_2019 RENAME column06 TO deleted;
ALTER TABLE users_2019 RENAME column07 TO lon;
ALTER TABLE users_2019 RENAME column08 TO lat;
ALTER TABLE users_2019 RENAME column09 TO country_code;
ALTER TABLE users_2019 RENAME column10 TO state;
ALTER TABLE users_2019 RENAME column11 TO city_name;
ALTER TABLE users_2019 RENAME column12 TO user_location;


ALTER TABLE users_2021 RENAME column00 TO user_id;
ALTER TABLE users_2021 RENAME column01 TO login;
ALTER TABLE users_2021 RENAME column02 TO company;
ALTER TABLE users_2021 RENAME column03 TO created_at;
ALTER TABLE users_2021 RENAME column04 TO type;
ALTER TABLE users_2021 RENAME column05 TO fake;
ALTER TABLE users_2021 RENAME column06 TO deleted;
ALTER TABLE users_2021 RENAME column07 TO lon;
ALTER TABLE users_2021 RENAME column08 TO lat;
ALTER TABLE users_2021 RENAME column09 TO country_code;
ALTER TABLE users_2021 RENAME column10 TO state;
ALTER TABLE users_2021 RENAME column11 TO city_name;
ALTER TABLE users_2021 RENAME column12 TO user_location;


-- Rename columns in projects table
ALTER TABLE projects RENAME column00 TO id;
ALTER TABLE projects RENAME column01 TO url;
ALTER TABLE projects RENAME column02 TO owner_id;
ALTER TABLE projects RENAME column03 TO name;
ALTER TABLE projects RENAME column04 TO description;
ALTER TABLE projects RENAME column05 TO language;
ALTER TABLE projects RENAME column06 TO created_at;
ALTER TABLE projects RENAME column07 TO forked_from;
ALTER TABLE projects RENAME column08 TO deleted;
ALTER TABLE projects RENAME column09 TO updated_at;

-- Rename columns in followers table
ALTER TABLE followers RENAME column0 TO user_id;
ALTER TABLE followers RENAME column1 TO follower_id;
ALTER TABLE followers RENAME column2 TO created_at;

-- Rename columns in watchers table
ALTER TABLE watchers RENAME column0 TO repo_id;
ALTER TABLE watchers RENAME column1 TO user_id;
ALTER TABLE watchers RENAME column2 TO created_at;


-- Rename columns in organization_members table
ALTER TABLE organization_members RENAME column0 TO org_id;
ALTER TABLE organization_members RENAME column1 TO user_id;
ALTER TABLE organization_members RENAME column2 TO created_at;

EOF

# Verify if the tables were created successfully
if [ $? -eq 0 ]; then
  echo "All tables loaded successfully from CSV files into DuckDB database."
else
  echo "Failed to load some or all CSV files into DuckDB database."
fi