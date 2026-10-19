/* Customer Master */
CREATE TABLE IF NOT EXISTS silver.customer_master(
	customer_id TEXT PRIMARY KEY,
	customer_name TEXT,
	customer_type TEXT,
	channel TEXT,
	province TEXT,
	region TEXT,
	address TEXT,
	phone BIGINT,
	tax_code DOUBLE PRECISION,
	join_date DATE,
	credit_limit BIGINT,
	status TEXT
);
INSERT INTO silver.customer_master(
	customer_id,
	customer_name,
	customer_type,
	channel,
	province,
	region,
	address,
	phone,
	tax_code,
	join_date,
	credit_limit,
	status
)
SELECT 
	customer_id,
	customer_name,
	customer_type,
	channel,
	province,
	region,
	address,
	phone,
	tax_code,
	join_date::DATE,
	credit_limit,
	status
FROM bronze.customer_master

/* Distributor Master */
CREATE TABLE IF NOT EXISTS silver.distributor_master(
	distributor_id TEXT PRIMARY KEY,
	distributor_name TEXT,
	tier TEXT,
	channel TEXT,
	province TEXT,
	region TEXT,
	contact_person TEXT,
	phone BIGINT,
	email TEXT,
	tax_code BIGINT,
	join_date DATE,
	credit_limit BIGINT,
	status TEXT,
	assigned_supervisor_id TEXT
);
INSERT INTO silver.distributor_master(
	distributor_id ,
	distributor_name ,
	tier ,
	channel ,
	province ,
	region ,
	contact_person ,
	phone ,
	email ,
	tax_code ,
	join_date ,
	credit_limit ,
	status ,
	assigned_supervisor_id 
)
SELECT
	distributor_id ,
	distributor_name ,
	tier ,
	channel ,
	province ,
	region ,
	contact_person ,
	phone ,
	email ,
	tax_code ,
	join_date::DATE ,
	credit_limit ,
	status ,
	assigned_supervisor_id 
FROM bronze.distributor_master
select * from silver.distributor_master

/* Distributor Orders */
CREATE TABLE IF NOT EXISTS silver.distributor_orders(
	order_id TEXT ,
	order_date DATE,
	distributor_id TEXT,
	region TEXT,
	channel TEXT,
	product_id TEXT,
	product_category TEXT,
	qty_ordered BIGINT,
	qty_delivered BIGINT,
	fill_rate_pct DOUBLE PRECISION,
	unit_price_list BIGINT,
	distributor_price BIGINT,
	gross_amount BIGINT,
	delivered_amount BIGINT,
	expected_delivery_date DATE,
	actual_delivery_date DATE,
	ontime_delivery TEXT,
	delivery_status TEXT,
	payment_terms TEXT
);
INSERT INTO silver.distributor_orders(
	order_id ,
	order_date ,
	distributor_id ,
	region ,
	channel ,
	product_id  ,
	product_category ,
	qty_ordered ,
	qty_delivered ,
	fill_rate_pct ,
	unit_price_list ,
	distributor_price ,
	gross_amount ,
	delivered_amount ,
	expected_delivery_date ,
	actual_delivery_date ,
	ontime_delivery ,
	delivery_status ,
	payment_terms 
)
SELECT
	order_id ,
	order_date::DATE ,
	distributor_id ,
	region ,
	channel ,
	product_id  ,
	product_category ,
	qty_ordered ,
	qty_delivered ,
	fill_rate_pct ,
	unit_price_list ,
	distributor_price ,
	gross_amount ,
	delivered_amount ,
	expected_delivery_date::DATE ,
	actual_delivery_date::DATE ,
	ontime_delivery ,
	delivery_status ,
	payment_terms 
FROM bronze.distributor_orders

/* Employee Master */
CREATE TABLE IF NOT EXISTS silver.employee_master(
	employee_id TEXT,
	full_name TEXT,
	gender TEXT,
	date_of_birth DATE,
	join_date DATE,
	position TEXT,
	region TEXT,
	team TEXT,
	email TEXT,
	phone BIGINT,
	status TEXT,
	version TEXT,
	effective_date DATE,
	resign_date DATE,
	transfer_note TEXT,
	is_latest INT
);
INSERT INTO silver.employee_master(
	employee_id,
	full_name,
	gender,
	date_of_birth,
	join_date,
	position,
	region,
	team,
	email,
	phone,
	status,
	version,
	effective_date,
	resign_date,
	transfer_note,
	is_latest
)
SELECT
	employee_id,
	full_name,
	gender,
	date_of_birth::DATE,
	join_date::DATE,
	position,
	region,
	team,
	email,
	phone,
	status,
	version,
	effective_date::DATE,
	CASE
    WHEN resign_date IS NULL THEN NULL
    ELSE resign_date::DATE
	END AS resign_date,
	transfer_note::TEXT,
	is_latest::INT
FROM bronze.employee_master

/* Sales Target Plan */
CREATE TABLE IF NOT EXISTS silver.sales_target_plan(
	plan_version TEXT,
	version_date DATE,
	effective_from DATE,
	effective_to DATE,
	employee_id TEXT,
	employee_name TEXT,
	region TEXT,
	team TEXT,
	year BIGINT,
	month BIGINT,
	target_revenue BIGINT,
	target_quantity BIGINT,
	target_new_customers BIGINT,
	is_latest INT
);
INSERT INTO silver.sales_target_plan(
	plan_version,
	version_date,
	effective_from,
	effective_to,
	employee_id,
	employee_name,
	region,
	team,
	year,
	month,
	target_revenue,
	target_quantity,
	target_new_customers,
	is_latest
)
SELECT
	plan_version,
	version_date::DATE,
	effective_from::DATE,
	effective_to::DATE,
	employee_id,
	employee_name,
	region,
	team,
	year,
	month,
	target_revenue,
	target_quantity,
	target_new_customers,
	is_latest::INT
FROM bronze.sales_target_plan

/* Product Master */
CREATE TABLE IF NOT EXISTS silver.product_master(
	product_id TEXT PRIMARY KEY,
	category TEXT,
	sub_category TEXT,
	unit TEXT,
	unit_price BIGINT,
	cost_price BIGINT,
	weight_gram BIGINT,
	status TEXT,
	launch_date DATE
);
INSERT INTO silver.product_master(
	product_id,
	category,
	sub_category,
	unit,
	unit_price,
	cost_price,
	weight_gram,
	status,
	launch_date
)
SELECT
	product_id,
	category,
	sub_category,
	unit,
	unit_price,
	cost_price,
	weight_gram,
	status,
	launch_date::DATE
FROM bronze.product_master

/* Promotion Program */
CREATE TABLE IF NOT EXISTS silver.promotion_program(
	promotion_id TEXT PRIMARY KEY,
	promotion_name TEXT,
	promotion_type TEXT,
	target_channel TEXT,
	target_region TEXT,
	start_date DATE,
	end_date DATE,
	applicable_products TEXT,
	discount_pct BIGINT,
	min_order_quantity BIGINT,
	budget_vnd BIGINT,
	actual_cost_vnd BIGINT,
	status TEXT,
	created_by TEXT
);
INSERT INTO silver.promotion_program(
	promotion_id,
	promotion_name,
	promotion_type,
	target_channel,
	target_region,
	start_date,
	end_date,
	applicable_products,
	discount_pct,
	min_order_quantity,
	budget_vnd,
	actual_cost_vnd,
	status,
	created_by
)
SELECT
	promotion_id,
	promotion_name,
	promotion_type,
	target_channel,
	target_region,
	start_date::DATE,
	end_date::DATE,
	applicable_products,
	discount_pct,
	min_order_quantity,
	budget_vnd,
	actual_cost_vnd,
	status,
	created_by
FROM bronze.promotion_program

/* Return Transactions */
CREATE TABLE IF NOT EXISTS silver.return_transactions(
	return_id TEXT PRIMARY KEY,
	original_order_id TEXT,
	return_date DATE,
	customer_id TEXT,
	employee_id TEXT,
	product_id TEXT,
	region TEXT,
	province TEXT,
	return_quantity BIGINT,
	unit_price BIGINT,
	return_amount BIGINT,
	return_reason TEXT,
	status TEXT
);
INSERT INTO silver.return_transactions(
	return_id,
	original_order_id,
	return_date,
	customer_id,
	employee_id,
	product_id,
	region,
	province,
	return_quantity,
	unit_price,
	return_amount,
	return_reason,
	status
)
SELECT
	return_id,
	original_order_id,
	return_date::DATE,
	customer_id,
	employee_id,
	product_id,
	region,
	province,
	return_quantity,
	unit_price,
	return_amount,
	return_reason,
	status
FROM bronze.return_transactions

/* Sales Transaction */
CREATE TABLE IF NOT EXISTS silver.sales_transaction(
	order_id TEXT,
	order_date DATE,
	customer_id TEXT,
	region TEXT,
	province TEXT,
	channel TEXT,
	employee_id TEXT,
	product_id TEXT,
	product_category TEXT,
	quantity BIGINT,
	unit_price BIGINT,
	discount_pct BIGINT,
	discount_amount DOUBLE PRECISION,
	gross_amount BIGINT,
	net_amount DOUBLE PRECISION,
	delivery_status TEXT,
	payment_method TEXT,
	payment_status TEXT
);
INSERT INTO silver.sales_transaction(
	order_id,
	order_date,
	customer_id,
	region,
	province,
	channel,
	employee_id,
	product_id,
	product_category,
	quantity,
	unit_price,
	discount_pct,
	discount_amount,
	gross_amount,
	net_amount,
	delivery_status,
	payment_method,
	payment_status
)
SELECT
	order_id,
	order_date::DATE,
	customer_id,
	region,
	province,
	channel,
	employee_id,
	product_id,
	product_category,
	quantity,
	unit_price,
	discount_pct,
	discount_amount,
	gross_amount,
	net_amount,
	delivery_status,
	payment_method,
	payment_status
FROM bronze.sales_transaction
select * from silver.sales_transaction

/* Territory Mapping */
CREATE TABLE IF NOT EXISTS silver.territory_mapping(
	territory_id TEXT PRIMARY KEY,
	employee_id TEXT,
	customer_id TEXT,
	region TEXT,
	team TEXT,
	effective_date DATE,
	expiry_date DATE,
	version TEXT
);
INSERT INTO silver.territory_mapping(
	territory_id,
	employee_id,
	customer_id,
	region,
	team,
	effective_date,
	expiry_date,
	version
)
SELECT
	territory_id,
	employee_id,
	customer_id,
	region,
	team,
	effective_date::DATE,
	expiry_date::DATE,
	version
FROM bronze.territory_mapping
select * from silver.territory_mapping