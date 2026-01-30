CREATE TABLE inventory_data (
    sku_id VARCHAR(15),
    category VARCHAR(30),
	record_date DATE,
    avg_daily_demand INT,
    lead_time_days INT,
    unit_cost NUMERIC(10,2),
    holding_cost_pct NUMERIC(5,2),
    stockout_cost NUMERIC(10,2),
    current_inventory INT,
    supplier_rating NUMERIC(3,1)
);

--

SELECT COUNT(*) FROM inventory_data;

--

SELECT * FROM inventory_data LIMIT 10;

--

SELECT
    category,
    COUNT(*) AS sku_count
FROM inventory_data
GROUP BY category
ORDER BY sku_count DESC;

--

SELECT
    category,
    ROUND(AVG(avg_daily_demand), 2) AS avg_demand,
    ROUND(AVG(current_inventory), 2) AS avg_inventory
FROM inventory_data
GROUP BY category;

--

SELECT
    sku_id,
    category,
    avg_daily_demand,
    lead_time_days,
    current_inventory,
    CASE
        WHEN current_inventory < avg_daily_demand * lead_time_days THEN 'Understocked'
        WHEN current_inventory > avg_daily_demand * lead_time_days * 1.5 THEN 'Overstocked'
        ELSE 'Balanced'
    END AS inventory_status
FROM inventory_data;

--

SELECT
    sku_id,
    category,
    avg_daily_demand,
    lead_time_days,
    current_inventory
FROM inventory_data
WHERE current_inventory < avg_daily_demand * lead_time_days;

--

SELECT
    sku_id,
    ROUND(current_inventory * unit_cost * holding_cost_pct, 2) AS holding_cost
FROM inventory_data;

--

SELECT
    sku_id,
    category,
    stockout_cost
FROM inventory_data
ORDER BY stockout_cost DESC
LIMIT 10;

--

SELECT
    sku_id,
    supplier_rating,
    avg_daily_demand,
    current_inventory
FROM inventory_data
WHERE supplier_rating < 3;

--

SELECT
    record_date,
    ROUND(AVG(current_inventory), 2) AS avg_inventory
FROM inventory_data
GROUP BY record_date
ORDER BY record_date;

--

SELECT
    sku_id,
    category,
    current_inventory,
    ROUND(
        AVG(current_inventory) OVER (), 2
    ) AS overall_avg_inventory
FROM inventory_data;

--

SELECT
    sku_id,
    category,
    current_inventory,
    RANK() OVER (
        PARTITION BY category
        ORDER BY current_inventory DESC
    ) AS inventory_rank_in_category
FROM inventory_data;

--

WITH reorder_point_calc AS (
    SELECT
        sku_id,
        avg_daily_demand,
        lead_time_days,
        current_inventory,
        (avg_daily_demand * lead_time_days) AS lead_time_demand,
        ROUND(
            1.65 * (avg_daily_demand * 0.3) * SQRT(lead_time_days)
        ) AS safety_stock
    FROM inventory_data
)
SELECT
    sku_id,
    lead_time_demand + safety_stock AS reorder_point,
    current_inventory,
    CASE
        WHEN current_inventory < lead_time_demand + safety_stock
        THEN 'Reorder Required'
        ELSE 'Stock OK'
    END AS reorder_status
FROM reorder_point_calc;

--

SELECT
    sku_id,
    CASE
        WHEN current_inventory < (avg_daily_demand * lead_time_days)
        THEN 1
        ELSE 0
    END AS stockout_flag
FROM inventory_data;









