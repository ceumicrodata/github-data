DATA := ~/Downloads/ghtorrent.db
analyses := $(wildcard analyses/*.sql)

all: $(analyses:.sql=.md)

analyses/%.md: analyses/%.sql $(DATA)
	poetry run dbt compile
	duckdb -readonly $(DATA) < target/compiled/ghtorrent/analyses/$*.sql > $@

build:
	poetry run dbt run

read:
	duckdb $(DATA) -c "create or replace table libraries as from read_parquet('../../data/beads/output/libraries.parquet');"
