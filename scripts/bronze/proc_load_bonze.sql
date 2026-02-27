
/* =========================================================================
   PHASE 3: AUTOMATION - ETL STORED PROCEDURE
   ========================================================================= */

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variable declarations for duration tracking
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
    table_start_time TIMESTAMP;
    table_end_time TIMESTAMP;
BEGIN 
    batch_start_time := clock_timestamp();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Starting Bronze Layer Data Load...';
    RAISE NOTICE '================================================';

    ---------------------------------------------------------------------------
    -- LOAD CRM SOURCE TABLES
    ---------------------------------------------------------------------------
    
    -- Load CRM Customer Info
    table_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and Loading CRM Customer Info';
    TRUNCATE TABLE bronze.crm_cust_info;
    COPY bronze.crm_cust_info
    FROM 'C:\datasets\source_crm\cust_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
    
    -- Load CRM Product Info
    table_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and Loading CRM Product Info';
    TRUNCATE TABLE bronze.crm_prd_info;
    COPY bronze.crm_prd_info 
    FROM 'C:\datasets\source_crm\prd_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
    
    -- Load CRM Sales Details
    table_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and Loading CRM Sales Details';
    TRUNCATE TABLE bronze.crm_sales_details;
    COPY bronze.crm_sales_details 
    FROM 'C:\datasets\source_crm\sales_details.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
    
    ---------------------------------------------------------------------------
    -- LOAD ERP SOURCE TABLES
    ---------------------------------------------------------------------------

    -- Load ERP Location A101
    table_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and Loading ERP Location A101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    COPY bronze.erp_loc_a101
    FROM 'C:\datasets\source_erp\LOC_A101.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
    
    -- Load ERP Customer AZ12
    table_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and Loading ERP Customer AZ12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    COPY bronze.erp_cust_az12
    FROM 'C:\datasets\source_erp\CUST_AZ12.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
    
    -- Load ERP Product Category G1V2
    table_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and Loading ERP Product Category G1V2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    COPY bronze.erp_px_cat_g1v2
    FROM 'C:\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
    
    ---------------------------------------------------------------------------
    -- BATCH COMPLETION & LOGGING
    ---------------------------------------------------------------------------

    batch_end_time := clock_timestamp();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Bronze Layer Data Load Completed Successfully!';
    RAISE NOTICE 'Total Batch Duration: %', (batch_end_time - batch_start_time);
    RAISE NOTICE '================================================';

-- Error Catching Safety Net
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
    RAISE NOTICE 'Error Message: %', SQLERRM;
    RAISE NOTICE '================================================';
    RAISE EXCEPTION 'Procedure failed due to the error above.';
END;
$$;
