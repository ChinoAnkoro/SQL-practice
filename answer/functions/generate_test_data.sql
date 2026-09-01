CREATE OR REPLACE FUNCTION generate_test_data(
    start_date DATE,
    end_date DATE
)

RETURNS VOID AS $$
DECLARE
    v_current_date DATE;
    v_order_id INTEGER;
BEGIN
    v_current_date := start_date;

    WHILE v_current_date <= end_date LOOP

    INSERT INTO orders (order_datetime)
    VALUES (
        v_current_date + (random() * interval '1 day')
    )
    RETURNING order_id INTO v_order_id;

    INSERT INTO order_details (
        order_id,
        product_id,
        quantity
    )
    VALUES (
        v_order_id,
        FLOOR(random() * 5 + 1)::INTEGER,
        FLOOR(random() * 5 + 1)::INTEGER
    );
    v_current_date := v_current_date + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;