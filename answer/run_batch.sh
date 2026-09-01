#!/bin/bash

TARGET_DATE=$1

#出力ディレクトリを作成
mkdir -p export

#日次売上集計
docker exec -i sql-batch-practice-db psql -U postgres -d practice_db \
    -c "SELECT summarize_daily_sales('$TARGET_DATE');"

#CSV出力
docker exec -i sql-batch-practice-db psql -U postgres -d practice_db \
    -c "\copy daily_sales_summary TO STDOUT WITH CSV HEADER" \
    > "export/daily_sales_summary_${TARGET_DATE}.csv"

echo "Batch completed."