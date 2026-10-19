/* mart_sales_vs_target */
/*
select * from gold.fact_sales;
select * from gold.dim_customers;
select * from gold.fact_returns;
select * from gold.fact_targets;
select * from gold.dim_employee;
*/

/*------------------------------------*/
CREATE TABLE IF NOT EXISTS gold.mart_sales_vs_target(
	plan_version TEXT,
	employee_id TEXT,
	employee_name TEXT,
	region TEXT,
	team TEXT,
	year BIGINT,
	month BIGINT,
	target_revenue BIGINT,
	total_revenue_include_return DOUBLE PRECISION,
	total_return_amount DOUBLE PRECISION,
	actual_revenue DOUBLE PRECISION,
	target_quantity BIGINT,
	total_quantity_include_return BIGINT,
	total_return_quantity BIGINT,
	actual_quantity BIGINT,
	target_new_customers BIGINT,
	actual_new_cus BIGINT
);
INSERT INTO gold.mart_sales_vs_target(
	plan_version ,
	employee_id ,
	employee_name ,
	region ,
	team ,
	year ,
	month ,
	target_revenue ,
	total_revenue_include_return ,
	total_return_amount ,
	actual_revenue ,
	target_quantity ,
	total_quantity_include_return ,
	total_return_quantity ,
	actual_quantity ,
	target_new_customers ,
	actual_new_cus 
)
with 
emp_prf as(
	select 
		plan_version,
		employee_id,
		employee_name,
		region,
		team,
		year,
		month,
		target_revenue,
		target_quantity,
		target_new_customers
	from gold.fact_targets
	order by employee_id, year, month
),
total_rev as(
	select /* Revenue Include Return */
		employee_id,
		extract (year from order_date)::int as year,
		extract (month from order_date)::int as month,
		sum(net_amount) as total_revenue_include_return
	from gold.fact_sales
	group by 
		employee_id,
		extract (year from order_date),
		extract (month from order_date)
	order by employee_id, year, month
),
total_return as(
	select /* Return */
		employee_id,
		extract (year from return_date)::int as year,
		extract (month from return_date)::int as month,
		sum(return_amount) as total_return_amount
	from gold.fact_returns
	group by 
		employee_id,
		extract (year from return_date),
		extract (month from return_date)
	order by employee_id, year, month
),
total_quant as(
	select /* Quantity Include Return */
		employee_id,
		extract (year from order_date)::int as year,
		extract (month from order_date)::int as month,
		sum(quantity) as total_quantity_include_return
	from gold.fact_sales
	group by 
		employee_id,
		extract (year from order_date),
		extract (month from order_date)
	order by employee_id, year, month
),
total_return_quantity as(
	select /* Return */
		employee_id,
		extract (year from return_date)::int as year,
		extract (month from return_date)::int as month,
		sum(return_quantity) as total_return_quantity
	from gold.fact_returns
	group by 
		employee_id,
		extract (year from return_date),
		extract (month from return_date)
	order by employee_id, year, month
),
new_cus as(
	select 
		employee_id,
		year,
		month,
		count(customer_id) as actual_new_cus
	from(
		select distinct * from(
			select 
				sl.employee_id,
				sl.customer_id,
				extract (year from cs.join_date) as year,
				extract (month from cs.join_date) as month
			from gold.fact_sales as sl
			join gold.dim_customers as cs
			using(customer_id)
		)
	)
	group by employee_id, year, month
)
select 
	prf.plan_version,
	prf.employee_id,
	prf.employee_name,
	prf.region,
	prf.team,
	prf.year,
	prf.month,
	
	prf.target_revenue,
	rev.total_revenue_include_return,
	ret.total_return_amount,
	rev.total_revenue_include_return - ret.total_return_amount as actual_revenue,
	
	prf.target_quantity,
	qnt.total_quantity_include_return,
	ret_qnt.total_return_quantity,
	qnt.total_quantity_include_return - ret_qnt.total_return_quantity as actual_quantity,
	
	prf.target_new_customers,
	ns.actual_new_cus
from emp_prf as prf
left join total_rev as rev using(employee_id, year, month)
left join total_return as ret using(employee_id, year, month)

left join total_quant as qnt using(employee_id, year, month)
left join total_return_quantity as ret_qnt using(employee_id, year, month)

left join new_cus as ns using(employee_id, year, month)

order by prf.employee_id, prf.plan_version, year, month;
select * from gold.mart_sales_vs_target;