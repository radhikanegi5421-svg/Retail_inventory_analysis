-- Schema for the cleaned retail inventory dataset.
-- Loaded from inventory_cleaned.csv (output of the Excel cleaning stage).

DROP TABLE IF EXISTS inventory;

CREATE TABLE inventory (
    sku_id           TEXT PRIMARY KEY,
    product_name     TEXT NOT NULL,
    category         TEXT NOT NULL,
    warehouse        TEXT NOT NULL,
    stock_qty        INTEGER NOT NULL CHECK (stock_qty >= 0),
    stock_corrected  TEXT,              -- 'Yes' if a negative value was corrected during cleaning
    unit_price       REAL NOT NULL,
    reorder_level    INTEGER NOT NULL,
    supplier         TEXT NOT NULL,
    last_restock_date DATE NOT NULL,
    stock_status     TEXT NOT NULL      -- 'OK' or 'Reorder Needed'
);

CREATE INDEX idx_inventory_category  ON inventory(category);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse);
CREATE INDEX idx_inventory_status    ON inventory(stock_status);
