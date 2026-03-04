/*
==============================================================
Quality Checks
==============================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:

    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
==============================================================
*/

--Analysing the table values 

select * from silver.crm_cust_info limit 3;


--analysing the null and removing the null 

select cst_key ,count(cst_key) as cnt from silver.crm_cust_info group by cst_key having count(*) > 1 ;


--check the unwanted spaces 

select cst_firstname from silver.crm_cust_info where trim(cst_firstname ) != cst_firstname ;
select * from silver.crm_cust_info where trim(cst_gndr)!=cst_gndr  ;

-- checking the data standardization and consistency

select cst_material_status ,count(*) from silver.crm_cust_info group by cst_material_status  ;



--table  2

--analysing the prd_info
select * from silver.crm_prd_info limit 1;

--analysing the null
select prd_id ,count(*) from silver.crm_prd_info group by prd_id having count(*)>2 or prd_id is null;

select *,
replace(substring(prd_key,1,5),'-','_') as cat_id
from bronze.crm_prd_info limit 1 ;

select * from bronze.erp_px_cat_g1v2 limit 1 ;


--checking the unwanted spaces and te no result values 
select  prd_nm from silver.crm_prd_info where trim(prd_nm) != prd_nm;

--checking the null and  negqtive values 
select prd_cost,prd_id from silver.crm_prd_info  where prd_cost is null or prd_cost <0;

--data statndardisation and consistency 

select distinct prd_line from silver.crm_prd_info;


--check for the invalid date orders 
select prd_key,
prd_start_dt,
prd_end_dt,
case 
	when lag(prd_end_dt)over(partition by prd_key order by prd_start_dt) is null then prd_start_dt
	else lag(prd_end_dt)over(partition by prd_key order by prd_start_dt) + interval '1 day'
end prd_start_dt_test,
lead(prd_start_dt )over(partition by prd_key order by prd_start_dt ) - interval '1 day' as prd_end_dt_tezt
from silver.crm_prd_info  where prd_end_dt <prd_start_dt ;

--table 3



SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LENGTH(sls_order_dt::text) <> 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;


--checking the sales = quantity * proce 
SELECT  
    csd.sls_sales,
    csd.sls_quantity,
    csd.sls_price,
    CASE 
        WHEN csd.sls_sales IS NULL 
            THEN COALESCE(csd.sls_price, 0) * COALESCE(csd.sls_quantity, 0)
        WHEN csd.sls_sales < 0 
            THEN csd.sls_sales * -1
        ELSE csd.sls_sales
    END AS sls_sales
FROM bronze.crm_sales_details csd  
WHERE 
    csd.sls_sales IS DISTINCT FROM 
        (csd.sls_quantity * csd.sls_price)
    OR csd.sls_sales IS NULL 
    OR csd.sls_quantity IS NULL 
    OR csd.sls_price IS NULL 
    OR csd.sls_quantity < 0 
    OR csd.sls_price < 0 
    OR csd.sls_sales < 0;


SELECT  
    csd.sls_sales,
    csd.sls_quantity,
    csd.sls_price,
    COALESCE(csd.sls_quantity,0) * COALESCE(csd.sls_price,0) AS calculated_sales
FROM bronze.crm_sales_details csd
WHERE 
    csd.sls_sales IS DISTINCT FROM 
        (COALESCE(csd.sls_quantity,0) * COALESCE(csd.sls_price,0))
    OR csd.sls_quantity < 0
    OR csd.sls_price < 0
    OR csd.sls_sales < 0;


select * from silver.crm_sales_details ;
select * from bronze.crm_sales_details where sls_order_dt > sls_due_dt or sls_order_dt < sls_ship_dt;

select csd.sls_ord_num,count(*)  from bronze.crm_sales_details csd  group by csd.sls_ord_num  ;



--table 4


--analysing the table 
SELECT cid, bdate, gen
FROM bronze.erp_cust_az12;
--analysing the null
select cid,count(*) from bronze.erp_cust_az12 group by cid having count(*)>1;

--analysing the coorect datga related to the customer ineformation 
select cid from bronze.erp_cust_az12 where substring(cid,4,length(cid)) not  in (select cst_key   from bronze.crm_cust_info );

select cst_key from bronze.crm_cust_info;

select 
cid,
case 
	when cid  like 'NAS%' then substring(cid,4,length(cid))
	else cid
end cid,
bdate,
gen,
count(*)over() as cnt
from bronze.erp_cust_az12
where case 
	when cid  like 'NAS%' then substring(cid,4,length(cid))
	else cid
end in (select distinct cst_key from bronze.crm_cust_info);


--analysing the bdate column of the table 
select bdate from bronze.erp_cust_az12  where bdate is null or (bdate<'1924-01-01' or bdate>current_date);

--anlaysing the gender
select distinct gen from bronze.erp_cust_az12 

select distinct gen from (select cid,bdate,
case 
	when upper(trim(gen)) = 'M' or trim(gen) = 'Female' then 'Female'
	when trim(gen) = 'M' or trim(gen) = 'Male' then 'Male'
	else 'N/a'
end as gen
from bronze.erp_cust_az12 );





--
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
	when upper(trim(gen)) = 'M' or trim(gen) = 'Female' then 'Female'
	when trim(gen) = 'M' or trim(gen) = 'Male' then 'Male'
	else 'N/a'
end as gen
from bronze.erp_cust_az12;

select * from silver.erp_cust_az12 eca ;





--table 5

--analysing the actual the completel data 
select * from bronze.erp_loc_a101 ela ;

--analysing the cid column
select 
replace(ela.cid,'-','') as cid,
ela.cntry
from bronze.erp_loc_a101 ela where  exists  (select 1 from bronze.crm_cust_info cci  where replace(ela.cid,'-','') =cci.cst_key );

--checking the realted table 
select * from bronze.crm_cust_info cci ;

--checking the cntry (data standardisation and normalisation )
select distinct cntry  from bronze.erp_loc_a101 ela ;

select distinct cntry, old_cntry from (select 
replace(cid,'-','') as cid,
cntry,
case 
	when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) in ('US','USA') then 'United States'
	when trim(cntry) in ('') or cntry is null then 'N/a'
	else trim(cntry)	
end as old_cntry
from bronze.erp_loc_a101 ela);


--table 6

--analysing the actual date of the table 
select * from bronze.erp_px_cat_g1v2 epcgv ;


--analysing the id 
select id from bronze.erp_px_cat_g1v2 epcgv where not  exists
(
select 1 from silver.crm_prd_info cpi where epcgv.id = cat_id);

select * from silver.crm_prd_info cpi ;

--unwanted spacvalues 

select * from bronze.erp_px_cat_g1v2 epcgv where trim(cat)!=cat or trim(subcat) != subcat or trim(epcgv.maintenance ) != epcgv.maintenance ;

--data standardisation and normalisation

select distinct epcgv.maintenance   from bronze.erp_px_cat_g1v2 epcgv ;





