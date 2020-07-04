#!/bin/bash

# PGPASSWORDをあらかじめ入れておくと、勝手に読み取ってくれる
CURRENT_RETRIES=5

until [ $CURRENT_RETRIES -eq 0 ] || psql --host $PG_HOST --username $PG_USER --dbname $PG_DATABASE --command 'select 1' > /dev/null 2>&1; do
  echo "Waiting for postgres server, $((CURRENT_RETRIES--)) remaining attempts..."
  sleep 1
done

if [ $CURRENT_RETRIES -eq 0 ]; then
  echo Failed health check
else
  echo DB ready
fi
