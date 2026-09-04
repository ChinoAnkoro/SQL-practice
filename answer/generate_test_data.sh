#!/bin/bash

START_DATE=$1
END_DATE=$2

docker exec -i sql-batch-practice-db psql -U postgres -d practice_db \
   -c "SELECT generate_test_data('$START_DATE', '$END_DATE');"