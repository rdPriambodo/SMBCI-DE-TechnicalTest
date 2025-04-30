# Project Overview
Implement Slowly Changing Dimension Type 2 using SQL Server based on the problem in SMBCI Data Engineer Test - SQL.pdf

## Flowchart
![Alt Text](https://github.com/rdPriambodo/SMBCI-DE-TechnicalTest/blob/c8532e1a5f5fdaaca3ab44a7a6aca716e3054723/1_SQL-Implementation/Flowchart-SDC2.png)

## Tasks Performed
- Created Stored Procedure to implement Slowly Changing Dimension Type 2 with SQL Server
- Tested for scenarios :
    - new customers
    - an existing customers changes address
    - an existing customers upgraded sub tier
    - multiple attribute updated
    - data got deleted in staging (subscription expired)
- Created Stored Procedure that combine implementation of SCD1 and SCD2

## Cases Handled
- Duplicate data in staging (raise error)
- Whitespace removed
- Handles Null data
- Implement Batching to handle large data

