/* Dim date */
CREATE TABLE IF NOT EXISTS gold.dim_date(
    date_key        INTEGER PRIMARY KEY,
    full_date       DATE NOT NULL UNIQUE,
    day             INTEGER NOT NULL,
    week            INTEGER NOT NULL,
    month           INTEGER NOT NULL,
    month_name      VARCHAR(20) NOT NULL,
    quarter         INTEGER NOT NULL,
    year            INTEGER NOT NULL,
    fiscal_year     INTEGER NOT NULL,
    fiscal_year_name VARCHAR(10) NOT NULL
);
INSERT INTO gold.dim_date (
    date_key,
    full_date,
    day,
    week,
    month,
    month_name,
    quarter,
    year,
    fiscal_year,
    fiscal_year_name
)
SELECT
    TO_CHAR(calendar_date, 'YYYYMMDD')::INTEGER AS date_key,
    calendar_date AS full_date,

    EXTRACT(DAY FROM calendar_date)::INTEGER AS day,

    -- ISO week number
    EXTRACT(WEEK FROM calendar_date)::INTEGER AS week,

    EXTRACT(MONTH FROM calendar_date)::INTEGER AS month,

    TO_CHAR(calendar_date, 'FMMonth') AS month_name,

    EXTRACT(QUARTER FROM calendar_date)::INTEGER AS quarter,

    EXTRACT(YEAR FROM calendar_date)::INTEGER AS year,

    -- Fiscal year starts on September 1 and ends on August 31
    CASE
        WHEN EXTRACT(MONTH FROM calendar_date) < 9
            THEN EXTRACT(YEAR FROM calendar_date)::INTEGER - 1
        ELSE EXTRACT(YEAR FROM calendar_date)::INTEGER
    END AS fiscal_year,

    'FY' ||
    CASE
        WHEN EXTRACT(MONTH FROM calendar_date) < 9
            THEN EXTRACT(YEAR FROM calendar_date)::INTEGER - 1
        ELSE EXTRACT(YEAR FROM calendar_date)::INTEGER
    END AS fiscal_year_name

FROM generate_series(
    DATE '2020-01-01',
    DATE '2035-12-31',
    INTERVAL '1 day'
) AS dates(calendar_date);

/* dim_employees */
CREATE TABLE IF NOT EXISTS gold.dim_employee(
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
INSERT INTO gold.dim_employee(
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
	case version
		when 'v1' then 0
		when 'v2' then 1
	end as is_latest
FROM silver.employee_master;
select * from gold.dim_employee;

/* dim_customers */
CREATE TABLE IF NOT EXISTS gold.dim_customers(
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
INSERT INTO gold.dim_customers(
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
SELECT DISTINCT *
FROM silver.customer_master;
select * from gold.dim_customers;

/* dim_products */
CREATE TABLE IF NOT EXISTS gold.dim_products(
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
INSERT INTO gold.dim_products(
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
SELECT DISTINCT *
FROM silver.product_master;
select * from gold.dim_products;

/* dim_distributors */
CREATE TABLE IF NOT EXISTS gold.dim_distributors(
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
INSERT INTO gold.dim_distributors(
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
SELECT DISTINCT *
FROM silver.distributor_master;
select * from gold.dim_distributors;

/* fact_sales */
CREATE TABLE IF NOT EXISTS gold.fact_sales(
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
INSERT INTO gold.fact_sales(
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
SELECT DISTINCT *
FROM silver.sales_transaction;
select * from gold.fact_sales;

/* fact_targets */
CREATE TABLE IF NOT EXISTS gold.fact_targets(
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
INSERT INTO gold.fact_targets(
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
SELECT DISTINCT *
FROM silver.sales_target_plan;
select * from gold.fact_targets;

/* fact_returns */
CREATE TABLE IF NOT EXISTS gold.fact_returns(
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
INSERT INTO gold.fact_returns(
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
SELECT DISTINCT *
FROM silver.return_transactions;
select * from gold.fact_returns;





