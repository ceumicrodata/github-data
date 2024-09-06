# Purpose: A hacky script to create a database of commtis of GHtorrent
# Followed this way because some timestamps are not in the correct format, R 
# can however convert them 

# The original commtis data is split into chunks which leads to 678 files

# Load the necessary libraries
library(pacman)
library(data.table)
library(duckdb)
p_load(lubridate)
p_load(fasttime)

# Connect to the database
con <- dbConnect(duckdb::duckdb(), "data/commits_database.db")

chunk_list <- list.files(
  "../../../../../Volumes/aaron_ssd/data/ghtorrent/mysql-2019-06-01/commit_chunks/")
# Loop through the chunks and load them into the database
for (b in chunk_list) {
  filepath <- paste0("../../../../../Volumes/aaron_ssd/data/ghtorrent/mysql-2019-06-01/commit_chunks/", b)
  commits <- fread(filepath)
  
  # Convert V6 to POSIXct if it's character
  if (sapply(commits, class)[6] == "character") {
    commits[, V6 := fastPOSIXct(V6)]
  } else {
    print("nothing to do")
  }
  
  # Convert V6 to daily date using fasttime excluding the seconds and minutes
  commits[, V6 := as.Date(fastPOSIXct(V6))]
  
  # Drop V2
  commits[, V2 := NULL]
  
  # Create new column quarter with lubridate which has quarter and year
  commits[, quarter := paste0("Q", quarter(V6), "-", year(V6))]

  # Append to the duckdb database or create if it doesn't exist
  dbWriteTable(con, "commits", commits, append = TRUE)
  
  rm(commits)
  print(b)
}

# In the database create a new table which groups the commits by 
# - Quarter 
# - committer_id (V4)
# - project_id (V5)
# and counts the number of commits
# and the number of unique_days liek this query 

query <- "CREATE table commit_groups as SELECT
quarter,
V4,
V5,
COUNT(*) AS commit_counts,
COUNT(DISTINCT V6) AS days_count
FROM
commits
GROUP BY
quarter,
V4,
V5
ORDER BY
quarter,
V4,
V5;"

dbExecute(con, query)

dbDisconnect(con)


