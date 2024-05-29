#!/bin/bash

duckdb users_database.db <<EOF
-- Create the table and read data from the CSV file
CREATE OR REPLACE TABLE users AS SELECT * FROM read_csv_auto('users.csv', ignore_errors=true);

-- Rename the columns
ALTER TABLE users RENAME column00 TO user_id;
ALTER TABLE users RENAME column01 TO login;
ALTER TABLE users RENAME column02 TO company;
ALTER TABLE users RENAME column03 TO created_at;
ALTER TABLE users RENAME column04 TO type;
ALTER TABLE users RENAME column05 TO fake;
ALTER TABLE users RENAME column06 TO deleted;
ALTER TABLE users RENAME column07 TO lon;
ALTER TABLE users RENAME column08 TO lat;
ALTER TABLE users RENAME column09 TO country_code;
ALTER TABLE users RENAME column10 TO state;
ALTER TABLE users RENAME column11 TO city_name;
ALTER TABLE users RENAME column12 TO user_location;

-- Delete users where country_code is \N
DELETE FROM users WHERE country_code = '\N';

-- Export the table to a Parquet file
COPY (SELECT * FROM users) TO 'users.parquet' (FORMAT 'parquet');

EOF