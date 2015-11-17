#!/bin/bash
exec /sbin/setuser postgres  /usr/lib/postgresql/$PG_MAJOR/bin/postgres -D $PGDATA
