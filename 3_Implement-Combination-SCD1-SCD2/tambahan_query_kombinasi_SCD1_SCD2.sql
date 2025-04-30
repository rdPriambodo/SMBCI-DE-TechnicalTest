UPDATE trg
SET trg.phone = LTRIM(RTRIM(src.phone)), trg.monthly_fee = src.monthly_fee
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
	);