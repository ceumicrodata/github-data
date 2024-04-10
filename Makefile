RELATIONS := commits issues comments

all: temp/u2u.csv
temp/u2u.csv: src/project/merge.sql $(foreach table,$(RELATIONS),temp/u2u_$(table).csv) 
	duckdb < $<
temp/u2u_%.csv: temp/%.parquet src/project/u2u.sql
	echo "create table relation as from read_parquet('$<');" > temp.sql
	cat src/project/u2u.sql >> temp.sql
	echo "to '$@' (format csv);" >> temp.sql
	duckdb < temp.sql
temp/%.parquet: src/filter/%.sql temp/events.db temp/sample_users.parquet temp/sample_projects.parquet
	duckdb -readonly temp/events.db < $<
temp/sample_users.parquet: src/filter/export_sample.sql temp/ghtorrent.db 
	duckdb -readonly temp/ghtorrent.db < $<