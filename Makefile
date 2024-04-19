RELATIONS := commits issues comments organizations editors owners
.PRECIOUS: *.parquet

all: temp/u2u.parquet
data/days.parquet: src/filter/days.sql temp/events.db
	duckdb -readonly temp/events.db < $<
temp/u2u.parquet: src/project/merge.sql  
	duckdb < $<
src/project/merge.sql: $(foreach table,$(RELATIONS),temp/u2u_$(table).parquet)
	echo "copy (" > $@
	for table in $(RELATIONS) ; do \
		echo "(select user1, user2, n_groups as n_links, '$$table' as relation, language from 'temp/u2u_$$table.parquet') union all" >> $@; \
	done
	echo "(select user1, user2, n_groups as n_links, 'none' as relation, language from 'temp/u2u_owners.parquet' where false)) to 'data/u2u.parquet' (format parquet);" >> $@
temp/u2u_%.parquet: temp/%.parquet src/project/u2u.sql
	echo "create table relation as from read_parquet('$<');" > temp.sql
	cat src/project/u2u.sql >> temp.sql
	echo "to '$@' (format parquet);" >> temp.sql
	duckdb < temp.sql
temp/editors.parquet: src/filter/editors.sql temp/ghtorrent.db data/users.parquet 
	duckdb -readonly temp/ghtorrent.db < $<
temp/organizations.parquet: src/filter/organizations.sql temp/ghtorrent.db data/users.parquet
	duckdb -readonly temp/ghtorrent.db < $<
temp/u2u_owners.parquet: src/project/u2u_owners.sql temp/events.db data/users.parquet data/projects.parquet
	duckdb -readonly temp/events.db < $<
temp/%.parquet: src/filter/%.sql temp/events.db data/users.parquet data/projects.parquet
	duckdb -readonly temp/events.db < $<
data/users.parquet data/projects.parquet &: src/filter/export_sample.sql temp/ghtorrent.db 
	duckdb -readonly temp/ghtorrent.db < $<