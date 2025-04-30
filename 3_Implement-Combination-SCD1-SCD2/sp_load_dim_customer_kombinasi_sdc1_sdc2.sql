USE [SMBCI_DE_TEST]
GO

/****** Object:  StoredProcedure [dbo].[load_dim_customer]    Script Date: 4/30/2025 10:03:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[load_dim_customer_kombinasi_sdc1_sdc2]
AS
BEGIN
	SET NOCOUNT ON;
	/**
	v2 - dibuat Batching untuk handle big data, Handle Data Staging Duplikat dan Terhapus, Handle whitespace
	**/
	DECLARE @now DATETIME = GETDATE();
	DECLARE @BatchSize INT = 10000;
	DECLARE @RowsAffected INT;

	-- Handle Duplikat
	IF EXISTS (
		SELECT customer_id
		FROM SMBCI_DE_TEST_STG.dbo.customer_staging
		GROUP BY customer_id
		HAVING COUNT(1) > 1
	)
	BEGIN
		RAISERROR ('Ditemukan customer_id Duplikat. Load aborted.', 16, 1);
		RETURN;
	END

	BEGIN TRY
		BEGIN TRAN;

		-- Update expiration_date dan is_current untuk data yang berubah
		SET @RowsAffected = 1;
		WHILE @RowsAffected > 0
		BEGIN
			WITH CTE_Update AS (
				SELECT TOP (@BatchSize) trg.*
				FROM dim_customer trg
				JOIN SMBCI_DE_TEST_STG.dbo.customer_staging src ON trg.customer_id = src.customer_id
				WHERE trg.is_current = 1 AND (
					   LTRIM(RTRIM(ISNULL(src.first_name, ''))) != LTRIM(RTRIM(ISNULL(trg.first_name, '')))
					OR LTRIM(RTRIM(ISNULL(src.last_name, ''))) != LTRIM(RTRIM(ISNULL(trg.last_name, '')))
					OR LTRIM(RTRIM(ISNULL(src.email, ''))) != LTRIM(RTRIM(ISNULL(trg.email, '')))
					--OR LTRIM(RTRIM(ISNULL(src.phone, ''))) != LTRIM(RTRIM(ISNULL(trg.phone, '')))
					OR LTRIM(RTRIM(ISNULL(src.address, ''))) != LTRIM(RTRIM(ISNULL(trg.address, '')))
					OR LTRIM(RTRIM(ISNULL(src.city, ''))) != LTRIM(RTRIM(ISNULL(trg.city, '')))
					OR LTRIM(RTRIM(ISNULL(src.state, ''))) != LTRIM(RTRIM(ISNULL(trg.state, '')))
					OR LTRIM(RTRIM(ISNULL(src.zip, ''))) != LTRIM(RTRIM(ISNULL(trg.zip, '')))
					OR LTRIM(RTRIM(ISNULL(src.subscription_tier, ''))) != LTRIM(RTRIM(ISNULL(trg.subscription_tier, '')))
					--OR ISNULL(src.monthly_fee, 0) != ISNULL(trg.monthly_fee, 0)
				)
			)
			UPDATE CTE_Update
			SET expiration_date = @now, is_current = 0;

			SET @RowsAffected = @@ROWCOUNT;
		END

		-- Overwrite untuk phone dan monthly_fee
		BEGIN
			WITH CTE_Overwrite AS (
				SELECT TOP (@BatchSize) trg.*, src.phone as new_phone, src.monthly_fee as new_monthly_fee
				FROM dim_customer trg
				JOIN SMBCI_DE_TEST_STG.dbo.customer_staging src ON trg.customer_id = src.customer_id
				WHERE trg.is_current = 1 
				AND ( ISNULL(LTRIM(RTRIM(src.phone)), '') != ISNULL(LTRIM(RTRIM(trg.phone)), '')
					OR ISNULL(src.monthly_fee, 0) != ISNULL(trg.monthly_fee, 0)
				)
				AND NOT ( LTRIM(RTRIM(ISNULL(src.first_name, ''))) != LTRIM(RTRIM(ISNULL(trg.first_name, '')))
					OR LTRIM(RTRIM(ISNULL(src.last_name, ''))) != LTRIM(RTRIM(ISNULL(trg.last_name, '')))
					OR LTRIM(RTRIM(ISNULL(src.email, ''))) != LTRIM(RTRIM(ISNULL(trg.email, '')))
					OR LTRIM(RTRIM(ISNULL(src.address, ''))) != LTRIM(RTRIM(ISNULL(trg.address, '')))
					OR LTRIM(RTRIM(ISNULL(src.city, ''))) != LTRIM(RTRIM(ISNULL(trg.city, '')))
					OR LTRIM(RTRIM(ISNULL(src.state, ''))) != LTRIM(RTRIM(ISNULL(trg.state, '')))
					OR LTRIM(RTRIM(ISNULL(src.zip, ''))) != LTRIM(RTRIM(ISNULL(trg.zip, '')))
					OR LTRIM(RTRIM(ISNULL(src.subscription_tier, ''))) != LTRIM(RTRIM(ISNULL(trg.subscription_tier, '')))
				)
			)
			UPDATE CTE_Overwrite
			SET phone = LTRIM(RTRIM(new_phone)), monthly_fee = new_monthly_fee;

			SET @RowsAffected = @@ROWCOUNT;
		END



		-- Insert Data baru dan terupdate
		SET @RowsAffected = 1;
		WHILE @RowsAffected > 0
		BEGIN
			WITH CTE_Insert AS (
				SELECT TOP (@BatchSize) src.*
				FROM SMBCI_DE_TEST_STG.dbo.customer_staging src
				LEFT JOIN dim_customer trg ON trg.customer_id = src.customer_id AND trg.is_current = 1
				WHERE trg.customer_id IS NULL OR (
					   LTRIM(RTRIM(ISNULL(src.first_name, ''))) != LTRIM(RTRIM(ISNULL(trg.first_name, '')))
					OR LTRIM(RTRIM(ISNULL(src.last_name, ''))) != LTRIM(RTRIM(ISNULL(trg.last_name, '')))
					OR LTRIM(RTRIM(ISNULL(src.email, ''))) != LTRIM(RTRIM(ISNULL(trg.email, '')))
					--OR LTRIM(RTRIM(ISNULL(src.phone, ''))) != LTRIM(RTRIM(ISNULL(trg.phone, '')))
					OR LTRIM(RTRIM(ISNULL(src.address, ''))) != LTRIM(RTRIM(ISNULL(trg.address, '')))
					OR LTRIM(RTRIM(ISNULL(src.city, ''))) != LTRIM(RTRIM(ISNULL(trg.city, '')))
					OR LTRIM(RTRIM(ISNULL(src.state, ''))) != LTRIM(RTRIM(ISNULL(trg.state, '')))
					OR LTRIM(RTRIM(ISNULL(src.zip, ''))) != LTRIM(RTRIM(ISNULL(trg.zip, '')))
					OR LTRIM(RTRIM(ISNULL(src.subscription_tier, ''))) != LTRIM(RTRIM(ISNULL(trg.subscription_tier, '')))
					--OR ISNULL(src.monthly_fee, 0) != ISNULL(trg.monthly_fee, 0)
				)
			)
			INSERT INTO dim_customer (
				 customer_id
				,first_name
				,last_name
				,email
				,phone
				,address
				,city
				,state
				,zip
				,subscription_tier
				,monthly_fee
				,effective_date
				,expiration_date
				,is_current
			)
			SELECT customer_id
				,LTRIM(RTRIM(first_name))
				,LTRIM(RTRIM(last_name))
				,LTRIM(RTRIM(email))
				,LTRIM(RTRIM(phone))
				,LTRIM(RTRIM(address))
				,LTRIM(RTRIM(city))
				,LTRIM(RTRIM(state))
				,LTRIM(RTRIM(zip))
				,LTRIM(RTRIM(subscription_tier))
				,monthly_fee
				,@now
				,NULL
				,1
			FROM CTE_Insert;

			SET @RowsAffected = @@ROWCOUNT;
		END

		--update expiration_date dan is_current untuk data yang terhapus di staging
		UPDATE dim_customer
		SET expiration_date = @now,
			is_current = 0
		WHERE is_current = 1 
		AND customer_id NOT IN ( SELECT customer_id FROM SMBCI_DE_TEST_STG.dbo.customer_staging );

		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END
GO


