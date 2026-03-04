/*
==============================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;

==============================================================
*/


create or replace procedure silver.load_silver()
language plpgsql
as $$
declare 
	batch_start_time timestamp;
	batch_end_time timestamp;
	table_start_time timestamp;
	table_end_time timestamp ;
	
begin 
	batch_start_time := clock_timestamp();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Starting Silver Layer Infrastructure & Data Load...';
    RAISE NOTICE '================================================';
	table_start_time :=clock_timestamp();
	raise notice '------ truncate the table  silver.crm_cust_info ----';
	truncate silver.crm_cust_info;
	raise notice '------ inserting into the table  silver.crm_cust_info ----';

	insert into silver.crm_cust_info (cst_id,cst_key,cst_firstname,cst_lastname,cst_material_status,cst_gndr,cst_create_date)
	(select 
	cst_id,
	cst_key,
	--check the unwanted spaces
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname ) as cst_lastname,
	-- checking the data standardization and consistency
	case 
		when cst_material_status = 'M' then 'Marriaged'
		when cst_material_status = 'S' then 'Single'
		else 'N/a'
	end as cst_material_status ,
	case 
		when t.cst_gndr = 'M' then 'Male'
		when t.cst_gndr = 'F' then 'Female'
		else 'N/a'
	end as cst_gndr,
	t.cst_create_date 
	from 
	(
	--analysing the null and removing the null 
	select *,row_number()over(partition by cst_id order by cst_create_date desc) as rnk from bronze.crm_cust_info  )t
	where rnk=1 and cst_id is not null);

	table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
--	table 2 
	table_start_time := clock_timestamp();
--	inserting and creating the new related table 

	raise notice '------ truncate the table  silver.crm_prd_info ----';
	raise notice '------ inserting into the table  silver.crm_prd_info ----';

	truncate table silver.crm_prd_info ;
	insert into silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
	SELECT 
	    prd_id,
	    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,--extract the new column
	    SUBSTRING(prd_key, 7, length(prd_key)) AS prd_key,--extract the new column
	    prd_nm,
	    coalesce(prd_cost,0) as prd_cost,--checking th null and the negtivelity of the data 
	    case upper(trim(prd_line))
	    	when 'M' then 'Mountain'
	    	when 'S' then 'Other Sales' 
	    	when 'R' then 'Road'
	    	when 'T' then 'Touring'
	    	else 'N/a'
	    end prd_line,--data normalisation and standardisation
	    cast(prd_start_dt as date),
	    cast(lead(prd_start_dt )over(partition by prd_key order by prd_start_dt ) - interval '1 day' as date)as  prd_end_dt -- asigning the coorect data values 
	FROM bronze.crm_prd_info;
	table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);

--	table 3 
	table_start_time := clock_timestamp();
	
	raise notice '------ truncate the table  silver.crm_sales_details ----';
	raise notice '------ inserting into the table  silver.crm_sales_details ----';
	truncate table silver.crm_sales_details ;
	INSERT INTO silver.crm_sales_details 
	(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
	
	SELECT 
	    sls_ord_num,
	    sls_prd_key,
	    sls_cust_id,
	
	        -- Order Date
	    CASE 
	        WHEN sls_order_dt = 0 
	             OR LENGTH(sls_order_dt::text) != 8 
	        THEN NULL
	        ELSE TO_DATE(sls_order_dt::text,'YYYYMMDD')
	    END AS sls_order_dt,
	
	    -- Ship Date
	    CASE 
	        WHEN sls_ship_dt = 0 
	             OR LENGTH(sls_ship_dt::text) != 8 
	        THEN NULL
	        ELSE TO_DATE(sls_ship_dt::text,'YYYYMMDD')
	    END AS sls_ship_dt,
	
	    -- Due Date
	    CASE 
	        WHEN sls_due_dt = 0 
	             OR LENGTH(sls_due_dt::text) != 8 
	        THEN NULL
	        ELSE TO_DATE(sls_due_dt::text,'YYYYMMDD')
	    END AS sls_due_dt,
	
	    -- Sales correction
	    CASE 
	        WHEN sls_sales IS NULL 
	             OR sls_sales IS DISTINCT FROM abs(sls_quantity) * abs(sls_price)
	        THEN abs(COALESCE(sls_price,0)) * abs(COALESCE(sls_quantity,0))
	        ELSE sls_sales
	    END,
	    -- Quantity correction
	    CASE 
	        WHEN sls_quantity IS NULL OR sls_quantity < 0
	        THEN abs(sls_sales) / NULLIF(abs(sls_price),0)
	        ELSE sls_quantity
	    END,
	    -- Price correction
	    CASE 
	        WHEN sls_price IS NULL OR sls_price < 0
	        THEN abs(sls_sales) / NULLIF(abs(sls_quantity),0)
	        ELSE sls_price
	    END
	FROM bronze.crm_sales_details;
	table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);

	
--	table 4
	table_start_time := clock_timestamp();

	raise notice '------ truncate the table  silver.erp_cust_az12 ----';
	raise notice '------ inserting into the table  silver.erp_cust_az12 ----';
	truncate table silver.erp_cust_az12;
	insert into silver.erp_cust_az12 (cid,bdate,gen)
	--actual query for the inseting into the table 
	select 
	case 
		when cid  like 'NAS%' then substring(cid,4,length(cid))
		else cid
	end cid,
	case 
		when bdate>current_date then null 
		else bdate
	end as bdate,
	case 
		when upper(trim(gen)) in('M' ,'FEMALE') then 'Female'
		when trim(gen) IN ('M','MALE') then 'Male'
		else 'N/a'
	end as gen
	from bronze.erp_cust_az12;
	
	table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
--	table 5
	table_start_time := clock_timestamp();
--	insert into the silver customer loation 
	raise notice '------ truncate the table  silver.erp_loc_a101 ----';
	raise notice '------ inserting into the table  silver.erp_loc_a101 ----';
	truncate table silver.erp_loc_a101;
	insert into silver.erp_loc_a101 (cid,cntry)
	--actual query for inserint into the table 
	select 
	replace(cid,'-','') as cid,
	case 
		when trim(cntry) = 'DE' then 'Germany'
		when trim(cntry) in ('US','USA') then 'United States'
		when trim(cntry) in ('') or cntry is null then 'N/a'
		else trim(cntry)	
	end as cntry --normaolis 
	from bronze.erp_loc_a101 ela;
	
	table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);
--	table 6
	table_start_time := clock_timestamp();
	raise notice '------ truncate the table  silver.erp_px_cat_g1v2 ----';
	raise notice '------ inserting into the table  silver.erp_px_cat_g1v2 ----';
	truncate table silver.erp_px_cat_g1v2;
	insert into silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
	select id,cat,subcat,maintenance from bronze.erp_px_cat_g1v2 epcgv ;
	
	table_end_time := clock_timestamp();
    RAISE NOTICE '   Completed in: %', (table_end_time - table_start_time);

	batch_end_time := clock_timestamp();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Silver Layer Data Load Completed Successfully!';
    RAISE NOTICE 'Total Batch Duration: %', (batch_end_time - batch_start_time);
	exception when others  then
	RAISE NOTICE '================================================';
    RAISE NOTICE 'ERROR OCCURRED DURING LOADING SILVER LAYER';
	RAISE NOTICE 'Error Message :%',sqlerrm ;
	RAISE NOTICE '================================================';
    RAISE EXCEPTION 'Procedure failed due to the error above.';

end;
$$;

call silver.load_silver();
