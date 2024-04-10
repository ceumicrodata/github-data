all: temp/commits.parquet
temp/%.parquet: src/filter/%.sql temp/events.db temp/sample_users.parquet temp/sample_projects.parquet
	duckdb -readonly temp/events.db < $<
temp/sample_users.parquet: src/filter/export_sample.sql temp/ghtorrent.db 
	duckdb -readonly temp/ghtorrent.db < $<