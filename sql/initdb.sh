#!/bin/sh
PG_HOST=aiti_db
PG_USER=aiti
PG_DB=aiti

PGPASSWORD=$POSTGRES_PASSWORD psql -U ${PG_USER} -h ${PG_HOST} -f tmp/users.sql
PGPASSWORD=$POSTGRES_PASSWORD psql -U ${PG_USER} -h ${PG_HOST} -f tmp/db.sql
PGPASSWORD=$POSTGRES_PASSWORD psql -U ${PG_USER} -h ${PG_HOST} ${PG_DB} -f tmp/create_tables.sql
PGPASSWORD=$POSTGRES_PASSWORD psql -U ${PG_USER} -h ${PG_HOST} ${PG_DB} -f tmp/fill_tables.sql
