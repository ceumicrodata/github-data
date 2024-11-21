#!/bin/bash

# Define the path to the DuckDB database directory
DATABASE_DIR=~/Desktop/duckdb_database_ghtorrent
DATABASE_FILE="$DATABASE_DIR/libraries_io_database.duckdb"

# Step 1: Check if directory for the database exists, create if not
if [ ! -d "$DATABASE_DIR" ]; then
  mkdir -p "$DATABASE_DIR"
  echo "Directory '$DATABASE_DIR' created."
else
  echo "Directory '$DATABASE_DIR' already exists."
fi

# Step 2: Create a valid DuckDB database file if it doesn't already exist
if [ ! -f "$DATABASE_FILE" ]; then
  # Initialize the database file
  duckdb "$DATABASE_FILE" "SELECT 1;" > /dev/null 2>&1
  echo "DuckDB database file '$DATABASE_FILE' created successfully."
else
  echo "DuckDB database file '$DATABASE_FILE' already exists."
fi

cd github_release


# Step 3: Load data into DuckDB tables from CSV files
duckdb "$DATABASE_FILE" <<EOF
-- Create or replace tables and load data from CSV files
CREATE OR REPLACE TABLE dependencies AS SELECT * FROM read_csv_auto('../../libraries.io/dependencies-1.6.0-2020-01-12.csv', ignore_errors=true);
CREATE OR REPLACE TABLE projects AS SELECT * FROM read_csv_auto('../../libraries.io/projects-1.6.0-2020-01-12.csv', ignore_errors=true);
CREATE OR REPLACE TABLE versions AS SELECT * FROM read_csv_auto('../../libraries.io/versions-1.6.0-2020-01-12.csv', ignore_errors=true);
EOF

# Step 4: Run additional processing and table creation in DuckDB
duckdb "$DATABASE_FILE" <<SQL

-- Drop any pre-existing tables to avoid conflicts
DROP TABLE IF EXISTS dependency_quarter_counts;
DROP TABLE IF EXISTS distinct_first_occurrences;
DROP TABLE IF EXISTS distinct_first_occurrences_with_quarter;
DROP TABLE IF EXISTS first_occurrence_dependencies;
DROP TABLE IF EXISTS first_occurrences_with_project_details;
DROP TABLE IF EXISTS joined_dependencies;
DROP TABLE IF EXISTS restricted_dependencies;
DROP TABLE IF EXISTS restricted_versions;

-- Step 1: Restrict versions to ID, Project ID, and Created Timestamp
CREATE TABLE restricted_versions AS
  SELECT
      ID AS version_id,
      "Project ID" AS project_id,
      "Created Timestamp" AS created_timestamp
  FROM
      versions;

-- Step 2: Restrict dependencies to Project ID, Dependency Project ID, and Version ID
CREATE TABLE restricted_dependencies AS
SELECT
    "Project ID" AS project_id,
    "Dependency Project ID" AS dependency_project_id,
    "Version ID" AS version_id
FROM
    dependencies;

-- Step 3: Join the dependencies with the versions to get the created timestamp for each dependency
CREATE TABLE joined_dependencies AS
SELECT
    d.project_id,
    d.dependency_project_id,
    v.created_timestamp
FROM
    restricted_dependencies d
JOIN
    restricted_versions v
ON
    d.version_id = v.version_id;

-- Step 4: Find the first occurrence of each dependency by created timestamp
CREATE TABLE first_occurrence_dependencies AS
SELECT
    project_id,
    dependency_project_id,
    MIN(created_timestamp) AS first_dependency_timestamp
FROM
    joined_dependencies
GROUP BY
    project_id, dependency_project_id;

-- Step 5: Join the first occurrence dependencies with the project details and format the columns
CREATE TABLE first_occurrences_with_project_details AS
  SELECT
      f.project_id AS project_id,
      f.dependency_project_id AS dependency_project_id,
      f.first_dependency_timestamp AS first_dependency_timestamp,
      LOWER(p.Language) AS language,
      LOWER(p."Repository URL") AS repository_url,
      LOWER(p."Package Manager ID") AS package_manager_id
  FROM
      first_occurrence_dependencies f
  JOIN
      projects p
  ON
      f.dependency_project_id = p.ID;

-- Remove duplicates to get distinct occurrences
CREATE TABLE distinct_first_occurrences AS
SELECT DISTINCT
    project_id,
    dependency_project_id,
    first_dependency_timestamp,
    language,
    repository_url,
    package_manager_id
FROM
    first_occurrences_with_project_details;

-- Add a date representing the first day of each quarter
CREATE TABLE distinct_first_occurrences_with_quarter AS
SELECT DISTINCT
    project_id,
    dependency_project_id,
    first_dependency_timestamp,
    CAST(
        CONCAT(
            strftime(first_dependency_timestamp, '%Y'), '-',  -- Extract the year
            CASE 
                WHEN strftime(first_dependency_timestamp, '%m') IN ('01', '02', '03') THEN '01-01'
                WHEN strftime(first_dependency_timestamp, '%m') IN ('04', '05', '06') THEN '04-01'
                WHEN strftime(first_dependency_timestamp, '%m') IN ('07', '08', '09') THEN '07-01'
                WHEN strftime(first_dependency_timestamp, '%m') IN ('10', '11', '12') THEN '10-01'
            END
        ) AS DATE
    ) AS quarter_start_date,  -- Convert to DATE type
    language,
    repository_url,
    package_manager_id
FROM
    distinct_first_occurrences;

-- Step 6: Count occurrences per dependency, quarter_start_date, and other details
CREATE TABLE dependency_quarter_counts AS
SELECT
    dependency_project_id,
    quarter_start_date,
    language,
    repository_url,
    package_manager_id,
    COUNT(*) AS occurrences
FROM
    distinct_first_occurrences_with_quarter
GROUP BY
    dependency_project_id,
    quarter_start_date,
    language,
    repository_url,
    package_manager_id;

-- Step 7: Output the results as a .parquet file
COPY (SELECT * FROM dependency_quarter_counts) TO 'output/dependency_quarter_counts.parquet' (FORMAT 'parquet');

SQL

# Final message
echo "Process completed and output saved as 'dependency_quarter_counts.parquet'"