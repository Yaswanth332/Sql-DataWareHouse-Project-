-- ===================================================================
-- quality checking the silver tables to create the viewsfor the dimensions and the facts tables for the users 
-- ===================================================================

-- ===================================================================
-- for creating the view of the gold.dim_customers
-- ===================================================================
select * from silver.crm_cust_info cci ;
select * from silver.erp_cust_az12 eca;
select * from silver.erp_loc_a101 ela ;
-- checking any duplicates in the table 
select customer_key , count(*) from gold.dim_customers group by  customer_key having count(*) >1;

-- ===================================================================
-- for creating the view of the gold.dim_products
-- ===================================================================
select * from gold.dim_customers;

select * from silver.crm_prd_info cpi ;
select * from silver.erp_px_cat_g1v2 epcgv ;

-- ===================================================================
-- for creating the view of the gold.facts_sales
-- ===================================================================

select * from gold.dim_customers ;
select * from gold.dim_products dp ;
select * from silver.crm_sales_details csd ;

select * from gold.fact_sales f  
left join gold.dim_customers dc 
on dc.customer_key= f.customer_key 
left  join gold.dim_products dp 
on dp.product_key =f.product_key
where dc.customer_key is null and dp.product_key  is null;






