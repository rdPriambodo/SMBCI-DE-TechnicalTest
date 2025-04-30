--TRUNCATE TABLE SMBCI_DE_TEST_STG.dbo.customer_staging;
--TRUNCATE TABLE dim_customer;

-- initial load
INSERT INTO SMBCI_DE_TEST_STG.dbo.customer_staging (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    address,
    city,
    state,
    zip,
    subscription_tier,
    monthly_fee
)
VALUES
(1, 'Budi', 'Santoso', 'budi.santoso@example.com', '0812-3456-7890', 'Jl. Merdeka No. 10', 'Jakarta', 'JK', '10110', 'Gold', 150000.00),
(2, 'Siti', 'Nurhaliza', 'siti.nurhaliza@example.com', '0813-2345-6789', 'Jl. Sudirman No. 25', 'Bandung', 'JB', '40123', 'Silver', 100000.00),
(3, 'Andi', 'Wijaya', 'andi.wijaya@example.com', '0814-1234-5678', 'Jl. Diponegoro No. 7', 'Surabaya', 'JI', '60234', 'Platinum', 250000.00),
(4, 'Dewi', 'Lestari', 'dewi.lestari@example.com', '0815-6789-0123', 'Jl. Ahmad Yani No. 88', 'Yogyakarta', 'YO', '55281', 'Gold', 150000.00),
(5, 'Rizky', 'Pratama', 'rizky.pratama@example.com', '0816-7890-1234', 'Jl. Gajah Mada No. 5', 'Medan', 'SU', '20112', 'Bronze', 50000.00);

select * from SMBCI_DE_TEST_STG.dbo.customer_staging;
EXEC load_dim_customer;
select * from dim_customer;

-- test update dan insert
UPDATE SMBCI_DE_TEST_STG.dbo.customer_staging
SET address = 'Jl. Gatot Subroto no.14'
where customer_id = 1;

UPDATE SMBCI_DE_TEST_STG.dbo.customer_staging
SET subscription_tier = 'Silver', monthly_fee = 100000.00
where customer_id = 5;

INSERT INTO SMBCI_DE_TEST_STG.dbo.customer_staging (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    address,
    city,
    state,
    zip,
    subscription_tier,
    monthly_fee
)
VALUES
(6, 'Agus', 'Saputra', 'agus.saputra@example.com', '0817-1234-1111', 'Jl. Kenari No. 21', 'Denpasar', 'BA', '80114', 'Bronze', 50000.00),
(7, 'Nina', 'Anggraini', 'nina.anggraini@example.com', '0818-2222-3333', 'Jl. Mawar No. 12', 'Malang', 'JI', '65111', 'Silver', 100000.00);

select * from SMBCI_DE_TEST_STG.dbo.customer_staging;
EXEC load_dim_customer;
select * from dim_customer;

-- test update multiple column
UPDATE SMBCI_DE_TEST_STG.dbo.customer_staging
SET subscription_tier = 'Platinum', monthly_fee = 250000.00, email = 'anggraini.nina@example.com'
where customer_id = 7;

select * from SMBCI_DE_TEST_STG.dbo.customer_staging;
EXEC load_dim_customer;
select * from dim_customer;

-- test data staging deleted
delete SMBCI_DE_TEST_STG.dbo.customer_staging where customer_id = 3

select * from SMBCI_DE_TEST_STG.dbo.customer_staging;
EXEC load_dim_customer;
select * from dim_customer;

-- error handling data duplikat
INSERT INTO SMBCI_DE_TEST_STG.dbo.customer_staging (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    address,
    city,
    state,
    zip,
    subscription_tier,
    monthly_fee
)
VALUES
(6, 'Agus', 'Saputra', 'agus.saputra@example.com', '0817-1234-1111', 'Jl. Kenari No. 21', 'Denpasar', 'BA', '80114', 'Bronze', 50000.00);

select * from SMBCI_DE_TEST_STG.dbo.customer_staging;
EXEC load_dim_customer;
select * from dim_customer;