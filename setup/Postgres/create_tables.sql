-- Table 1: item_categories
CREATE TABLE item_categories (
    category_code INTEGER PRIMARY KEY, 
    category_name VARCHAR(255), 
    category_description VARCHAR(255),
    ytd_sales INTEGER, 
    avg_price INTEGER, 
    _frequency NUMERIC -- mockaroo
);

-- Table 2: item_master
CREATE TABLE item_master (
    category_code INTEGER, 
    item_id INTEGER PRIMARY KEY,
    item_price NUMERIC, 
    item_upc VARCHAR(15) UNIQUE, 
    repl_qty INTEGER,
    _frequency INTEGER -- mockaroo
);
CREATE INDEX idx_item_upc ON item_master (item_upc);
ALTER TABLE IF EXISTS public.item_master
    ADD CONSTRAINT fk_item_category FOREIGN KEY (category_code)
    REFERENCES public.item_categories (category_code) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
    NOT VALID;

-- Table 3: retail_stores
CREATE TABLE retail_stores (
    store_id INTEGER PRIMARY KEY, 
    address VARCHAR(255),
    city VARCHAR (80),
    state VARCHAR (2),
    zipcode VARCHAR(10),
    longitude NUMERIC,
    latitude NUMERIC, 
    timezone VARCHAR(32)
);

-- Table 4: scans
CREATE TABLE scans (
    batch_id VARCHAR(48),
    scan_id VARCHAR(48) PRIMARY KEY,
    store_id INTEGER,
    scan_datetime DATETIME,
    item_upc VARCHAR(15),
    unit_qty INTEGER
);
ALTER TABLE IF EXISTS public.scans
    ADD CONSTRAINT fk_store_id FOREIGN KEY (store_id)
    REFERENCES public.retail_stores (store_id) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
    NOT VALID;
ALTER TABLE IF EXISTS public.scans
    ADD CONSTRAINT fk_item_upc FOREIGN KEY (item_upc)
    REFERENCES public.item_master (item_upc) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
    NOT VALID;
