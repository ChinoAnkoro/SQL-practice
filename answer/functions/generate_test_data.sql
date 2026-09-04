CREATE OR REPLACE FUNCTION generate_test_data(
    start_date DATE,
    end_date DATE
)

RETURNS VOID AS $$
DECLARE
    v_current_date DATE;
    v_order_id INTEGER;
    -- 追加
    v_product_id INTEGER;
    v_order_count INTEGER;
    v_order_index INTEGER;

    -- 追加
    -- 1注文あたりの最大購入数量
    c_max_quantity CONSTANT INTEGER := 5;

    -- 追加
    -- 1日あたりの最大注文件数
    c_max_order_per_day CONSTANT INTEGER := 10;
BEGIN
    -- 開始日が終了日より後の場合はエラー
    IF start_date > end_date THEN
        RAISE EXCEPTION
            '開始日委は終了日以前を指定してください。開始日: %, 終了日: %',
            start_date,
            end_date;
    END IF;

    -- 追加
    -- 商品が存在するか確認
    IF NOT EXISTS (
        SELECT 1
        FROM products
    ) THEN
        RAISE EXCEPTION
            '商品マスタに商品が存在しません。';
        END IF;

    -- 開始・終了ログ
    RAISE NOTICE
        'テストデータ生成開始：開始日=%, 終了日=%',
        start_date,
        end_date;

    v_current_date := start_date;

    -- 日付単位で処理
    WHILE v_current_date <= end_date LOOP
    -- 追加
    -- 1～10件の注文をランダムに生成
    v_order_count :=
        FLOOR(random() * c_max_order_per_day + 1)::INTEGER;

    RAISE NOTICE
        '処理日: %, 注文件数: %件',
        v_current_date,
        v_order_count;
    
    -- 追加
    -- 注文件数分ループ
    FOR v_order_index IN 1..v_order_count LOOP
        INSERT INTO orders (order_datetime)
        VALUES (
            v_current_date + (random() * interval '1 day')
        )
        RETURNING order_id INTO v_order_id;

        -- 商品をランダム取得
        SELECT product_id
        INTO v_product_id
        FROm products
        ORDER BY random()
        LIMIT 1;
        
        -- 商品が取得できなかった場合
        IF v_product_id IS NULL THEN
            RAISE EXCEPTION
                '商品を取得できませんでした。';
        END IF;

        -- 注文明細を登録
        INSERT INTO order_details (
            order_id,
            product_id,
            quantity
        )
        VALUES (
            v_order_id,
            v_product_id,
            FLOOR(random() * c_max_quantity + 1)::INTEGER
        );
        END LOOP;
        v_current_date := v_current_date + 1;
    END LOOP;

    -- 追加
    -- 完了ログ
    RAISE NOTICE
        'テストデータ生成完了：開始日=%, 終了日=%',
        start_date,
        end_date;
END;
$$ LANGUAGE plpgsql;