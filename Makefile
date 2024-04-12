RELATIONS := commits issues comments organizations editors

all: temp/u2u.parquet
temp/u2u.parquet: src/project/merge.sql $(foreach table,$(RELATIONS),temp/u2u_$(table).parquet) 
	duckdb < $<
temp/u2u_%.parquet: temp/%.parquet src/project/u2u.sql
	echo "create table relation as from read_parquet('$<');" > temp.sql
	cat src/project/u2u.sql >> temp.sql
	echo "to '$@' (format parquet);" >> temp.sql
	duckdb < temp.sql
temp/editors.parquet: src/filter/editors.sql temp/ghtorrent.db data/users.parquet 
	duckdb -readonly temp/ghtorrent.db < $<
temp/organizations.parquet: src/filter/organizations.sql temp/ghtorrent.db data/users.parquet
	duckdb -readonly temp/ghtorrent.db < $<
temp/%.parquet: src/filter/%.sql temp/events.db data/users.parquet data/projects.parquet
	duckdb -readonly temp/events.db < $<
data/users.parquet data/projects.parquet &: src/filter/export_sample.sql temp/ghtorrent.db 
	duckdb -readonly temp/ghtorrent.db < $<