#!/bin/bash

# 引数チェック
if [ "$#" -ne 2 ]; then
    echo "使用方法: $0 <開始日> <終了日>"
    exit 1
fi

START_DATE=$1
END_DATE=$2

echo "テストデータ生成開始"
echo "開始日: $START_DATE"
echo "終了日: $END_DATE"

docker exec -i sql-batch-practice-db psql -U postgres -d practice_db \
    -c "SELECT generate_test_data('$START_DATE', '$END_DATE');"

# SQL実行結果を確認
if [ $? -ne 0 ]; then
    echo "テストデータ生成に失敗しました"
    exit 1
fi

echo "テストデータ生成完了"