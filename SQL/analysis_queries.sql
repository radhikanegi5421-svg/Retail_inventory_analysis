-- ============================================================
-- Analysis queries on the cleaned inventory table.
-- Each query answers a real question a warehouse/ops manager
-- would actually ask — that's the logic behind picking these.
-- ============================================================

-- 1. Reorder alert list: which SKUs are below their reorder level right now?
--    This is the single most actionable output of the whole project —
--    it becomes the "Reorder Alerts" table on the Power BI dashboard.
SELECT sku_id, product_name, warehouse, stock_qty, reorder_level,
       (reorder_level - stock_qty) AS units_short
FROM inventory
WHERE stock_status = 'Reorder Needed'
ORDER BY units_short DESC;


-- 2. Stock value held by category (Stock_Qty * Unit_Price).
--    Tells finance/ops where money is tied up in stock.
SELECT category,
       COUNT(*)                         AS sku_count,
       SUM(stock_qty)                   AS total_units,
       ROUND(SUM(stock_qty * unit_price), 2) AS stock_value
FROM inventory
GROUP BY category
ORDER BY stock_value DESC;


-- 3. Warehouse-wise stock distribution.
--    Useful to spot if one warehouse is overstocked while another is thin.
SELECT warehouse,
       COUNT(*)       AS sku_count,
       SUM(stock_qty) AS total_units,
       ROUND(AVG(stock_qty), 1) AS avg_units_per_sku
FROM inventory
GROUP BY warehouse
ORDER BY total_units DESC;


-- 4. Supplier performance by value supplied (proxy metric, since we don't
--    have delivery-time data — total stock value currently sourced from
--    each supplier tells us who we depend on most).
SELECT supplier,
       COUNT(*) AS sku_count,
       ROUND(SUM(stock_qty * unit_price), 2) AS total_value_supplied
FROM inventory
GROUP BY supplier
ORDER BY total_value_supplied DESC;


-- 5. Slow-moving / aging stock: not restocked in the last 90 days
--    (relative to the latest restock date in the dataset, since this
--    is a static export rather than a live feed).
WITH latest_date AS (SELECT MAX(last_restock_date) AS d FROM inventory)
SELECT i.sku_id, i.product_name, i.warehouse, i.last_restock_date,
       CAST(julianday((SELECT d FROM latest_date)) - julianday(i.last_restock_date) AS INTEGER) AS days_since_restock
FROM inventory i
WHERE julianday((SELECT d FROM latest_date)) - julianday(i.last_restock_date) > 90
ORDER BY days_since_restock DESC;


-- 6. Top 5 highest-value SKUs currently in stock.
SELECT sku_id, product_name, category, stock_qty, unit_price,
       ROUND(stock_qty * unit_price, 2) AS stock_value
FROM inventory
ORDER BY stock_value DESC
LIMIT 5;


-- 7. Corrected-data audit trail: which rows had a negative-stock fix applied
--    during Excel cleaning? Kept queryable here for transparency.
SELECT sku_id, product_name, stock_qty, stock_corrected
FROM inventory
WHERE stock_corrected = 'Yes';
