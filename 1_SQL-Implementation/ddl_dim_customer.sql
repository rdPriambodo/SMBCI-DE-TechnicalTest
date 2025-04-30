CREATE TABLE dim_customer (
	customer_sk INT IDENTITY(1,1) PRIMARY KEY,
	customer_id INT,
	first_name varchar(50),
	last_name varchar(50),
	email varchar(100),
	phone varchar(20),
	address varchar(200),
	city varchar(50),
	state varchar(2),
	zip varchar(10),
	subscription_tier varchar(20),
	monthly_fee decimal(10,2),
	effective_date DATE,
	expiration_date DATE,
	is_current bit
)