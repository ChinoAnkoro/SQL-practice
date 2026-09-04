CREATE OR REPLACE FUNCTION summarize_daily_sales(
    target_date DATE
)
RETURNS VOID AS $$
-- 追加
DECLARE
    v_deleted_count INTEGER;
    v_inserted_count INTEGER;
BEGIN
    -- 追加
    -- 開始ログ
    RAISE NOTICE
        '日次売上集計開始：対象日=%',
        target_date;
    
    -- 既存の集計結果を削除
    DELETE FROM daily_sales_summary
    WHERE summary_date = target_date;

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    -- 追加
    RAISE NOTICE
        '既存集計結果削除：%件',
        v_deleted_count;
    -- 日次売上を集計して登録
    INSERT INTO daily_sales_summary (
        summary_date,
        product_id,
        total_quantity_sold,
        total_sales_amount
    )
    SELECT
        DATE(o.order_datetime) AS summary_date,
        od.product_id,
        SUM(od.quantity) AS total_quantity_sold,
        SUM(p.price * od.quantity) AS total_sales_amount
    FROM orders o
    JOIN order_details od
        ON o.order_id = od.order_id
    JOIN products p
        ON od.product_id = p.product_id
    WHERE DATE(o.order_datetime) = target_date
    GROUP BY
        DATE(o.order_datetime),
        od.product_id;

    GET DIAGNOSTICS v_inserted_count = ROW_COUNT;

    -- 追加
    RAISE NOTICE
        '日次売上集計登録：%件',
        v_inserted_count;

    -- 追加
    -- 完了ログ
    RAISE NOTICE
        '日次売上集計完了：対象日=%, 登録件数=%件',
        target_date,
        v_inserted_count;
END;
$$ LANGUAGE plpgsql;