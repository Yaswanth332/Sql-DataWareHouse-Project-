-- ================================================================================
-- ===================DDL Gold ================================================== 
-- this script will create the views for the gold layer ,so that the accsing the data id liitle bit easy for every one 
--======the gold layer represents the final layer of the facts and the dimesion table ======
--=======each view represent the a single dimension or the fact tables



-- --- this views can be  queries directly for analystical purpose 


--========================================================================================
-- create the gold.dim_customers view
--========================================================================================
drop view if exists gold.dim_products;
create view gold.dim_customers as 
select 
	row_number()over(order by cci.cst_id ) as customer_key,
	cci.cst_id as customer_id,
	cci.cst_key as customer_number,
	cci.cst_firstname as first_name,
	cci.cst_lastname as last_name,
	ela.cntry as country,
	cci.cst_material_status as marital_status,
	case 
		when cci.cst_gndr !='N/a' then cci.cst_gndr
		else coalesce(eca.gen,'N/a')
	end as gender,
	eca.bdate as birth_date,
	cci.cst_create_date as create_date
	from silver.crm_cust_info cci left  join silver.erp_cust_az12 eca  on cci.cst_key = eca.cid
	left join silver.erp_loc_a101 ela on cci.cst_key = ela.cid ;

--========================================================================================
-- create the gold.dim_products view
--========================================================================================
drop view if exists gold.dim_products;
create  view gold.dim_products as (
select 
row_number()over(order by cpi.prd_start_dt ,cpi.prd_key) as product_key,
cpi.prd_id as product_id,
cpi.prd_key as product_number,
cpi.prd_nm as product_name,
cpi.cat_id as catogery_id,
epcgv.cat as catogery,
epcgv.subcat as subcatogery,
epcgv.maintenance ,
cpi.prd_cost as  cost,
cpi.prd_line as product_line,
cpi.prd_start_dt as start_date
from silver.crm_prd_info cpi 
left join silver.erp_px_cat_g1v2 epcgv on cpi.cat_id=epcgv.id 
where cpi.prd_end_dt is null  --filtering out the all historical data;
);

--========================================================================================
-- create the gold.fact_sales view
--========================================================================================
drop view if exists gold.fact_sales;
create view gold.fact_sales as
SELECT 
sd.sls_ord_num as order_number,
pr.product_key,
cr.customer_key , 
sd.sls_order_dt as order_date, 
sd.sls_ship_dt as shipping_date, 
sd.sls_due_dt as due_date, 
sd.sls_sales as sales_amount, 
sd.sls_quantity as quantity , 
sd.sls_price as price
FROM silver.crm_sales_details sd
left join gold.dim_products pr 
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cr
on sd.sls_cust_id = cr.customer_id;



