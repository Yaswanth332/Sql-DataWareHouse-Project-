  --Creating the tables in the Silver schema  ,dop if the table already exist 
-- ==============================================================================
-- 1. CRM Customer Info
-- ==============================================================================
drop table if exists silver.crm_cust_info ;

create table silver.crm_cust_info (
	cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);


-- ==============================================================================
-- 2. CRM Product Info
-- ==============================================================================
drop table if exists silver.crm_prd_info;
	
CREATE TABLE silver.crm_prd_info (
    prd_id INT NOT NULL,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50) NOT NULL,
    prd_nm VARCHAR(100),
    prd_cost NUMERIC(10,2),
    prd_line VARCHAR(50),
    prd_start_dt DATE NOT NULL,
    prd_end_dt DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_date_range
        CHECK (prd_start_dt <= prd_end_dt) --making the constrain to avoid the date that are les than startdate
        
);
-- ==============================================================================
-- 3. CRM Sales Details
-- ==============================================================================
raise notice '------ droping  the table  silver.crm_sales_details ----';
raise notice '------ creating into the table  silver.crm_sales_details ----';
DROP TABLE IF EXISTS silver.crm_sales_details;
--creating the table with  the actual data types
CREATE TABLE silver.crm_sales_details(
    sls_ord_num VARCHAR(50) NOT NULL,
    sls_prd_key VARCHAR(50) NOT NULL,
    sls_cust_id INT NOT NULL,

    sls_order_dt DATE,
    sls_ship_dt DATE, 
    sls_due_dt DATE,

    sls_sales NUMERIC(20,2),
    sls_quantity NUMERIC(20,2),
    sls_price NUMERIC(20,2),

    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 

    CONSTRAINT valid_sales_check
        CHECK (sls_sales IS NULL OR sls_sales >= 0),

    CONSTRAINT valid_quantity_check
        CHECK (sls_quantity IS NULL OR sls_quantity >= 0),

    CONSTRAINT valid_price_check
        CHECK (sls_price IS NULL OR sls_price >= 0),

    CONSTRAINT valid_data_check
        CHECK (
            (sls_order_dt IS NULL OR sls_ship_dt IS NULL OR sls_order_dt <= sls_ship_dt)
            AND
            (sls_order_dt IS NULL OR sls_due_dt IS NULL OR sls_order_dt <= sls_due_dt)
        )
);
-- ==============================================================================
-- 4. ERP Location A101
-- ==============================================================================
DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 5. ERP Customer AZ12
-- ==============================================================================
DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 6. ERP Product Category G1V2
-- ==============================================================================
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
